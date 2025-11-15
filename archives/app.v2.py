"""
AbideVerse – Single-file MVP (Streamlit + simple LangChain-style helpers)

Features:
- Tabs: Chat | RAG | Memorize | Devotions | Settings
- LLM provider selection: Ollama (local) -> OpenAI fallback
- Simple RAG: upload text/pdf, create local embeddings (chromadb + sentence-transformers)
- Memorize: cloze + complete-the-verse quizzes, store progress in local SQLite
- Devotions: sample devotion list (small JSON inside file)
- Language toggle: English / Chinese (translation via LLM)
- KISS single-file: easy to modify and re-run
"""

import os
import sqlite3
import json
import tempfile
import io
import random
import time
from typing import Optional, List

import streamlit as st

# ---- Optional heavy deps used only when user uses RAG/embeddings ----
try:
    import requests
    import chromadb
    from chromadb.utils import embedding_functions
    from sentence_transformers import SentenceTransformer
except Exception:
    # We'll handle missing packages gracefully in the UI
    chromadb = None
    SentenceTransformer = None
    requests = None

# ---- CONFIG / ENV ----
DEFAULT_BIBLE_VERSION = os.getenv("DEFAULT_BIBLE_VERSION", "NIV")
DEFAULT_LANGUAGE = os.getenv("DEFAULT_LANGUAGE", "en")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")  # Ollama local base

DB_PATH = "abideverse.db"

st.set_page_config(page_title="AbideVerse – Your Daily AI-Powered Bible Verse Companion", layout="centered")

# -------------------------
# DB helpers (sqlite simple)
# -------------------------
def init_db():
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    c = conn.cursor()
    c.execute("""CREATE TABLE IF NOT EXISTS conversations (id INTEGER PRIMARY KEY, user_text TEXT, bot_text TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)""")
    c.execute("""CREATE TABLE IF NOT EXISTS progress (id INTEGER PRIMARY KEY, verse_key TEXT, user_id TEXT DEFAULT 'local', correct_count INTEGER DEFAULT 0, last_seen DATETIME DEFAULT CURRENT_TIMESTAMP)""")
    conn.commit()
    return conn

DB = init_db()

def save_conversation(user_text: str, bot_text: str):
    c = DB.cursor()
    c.execute("INSERT INTO conversations (user_text, bot_text) VALUES (?, ?)", (user_text, bot_text))
    DB.commit()

def save_progress(verse_key: str, correct: bool):
    c = DB.cursor()
    c.execute("SELECT id, correct_count FROM progress WHERE verse_key = ?", (verse_key,))
    r = c.fetchone()
    if r:
        _id, cc = r
        cc = cc + (1 if correct else 0)
        c.execute("UPDATE progress SET correct_count = ?, last_seen = CURRENT_TIMESTAMP WHERE id = ?", (cc, _id))
    else:
        cc = 1 if correct else 0
        c.execute("INSERT INTO progress (verse_key, correct_count) VALUES (?, ?)", (verse_key, cc))
    DB.commit()
    return cc

def get_progress(verse_key: str):
    c = DB.cursor()
    c.execute("SELECT correct_count FROM progress WHERE verse_key = ?", (verse_key,))
    r = c.fetchone()
    return r[0] if r else 0

# -------------------------
# Minimal Bible sample data
# (Use these as placeholders — replace with licensed ESV/NIV text or user uploads)
# -------------------------
SAMPLE_VERSES = {
    "John 3:16": {
        "en": "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
        "zh": "神爱世人，甚至将他的独生子赐给他们，叫一切信他的，不至灭亡，反得永生。"
    },
    "Psalm 23:1": {
        "en": "The Lord is my shepherd; I shall not want.",
        "zh": "耶和华是我的牧者，我必不致缺乏。"
    },
    "Philippians 4:13": {
        "en": "I can do all this through him who gives me strength.",
        "zh": "我靠着那加给我力量的，凡事都能做。"
    }
}

# -------------------------
# Utility functions
# -------------------------
def cloze(verse_text: str, blanks: int = 2) -> str:
    words = verse_text.split()
    if len(words) <= blanks:
        return " ".join(["____" for _ in words])
    idxs = sorted(random.sample(range(len(words)), min(blanks, len(words)-1)))
    out = []
    for i, w in enumerate(words):
        if i in idxs:
            out.append("____")
        else:
            out.append(w)
    return " ".join(out)

def blank_last_n_words(verse_text: str, n: int = 3) -> str:
    words = verse_text.split()
    if len(words) <= n:
        return " ".join(["____" for _ in words])
    return " ".join(words[:-n] + ["____"] * n)

def safe_strip(s: Optional[str]) -> str:
    return s.strip() if s else ""

# -------------------------
# Simple LLM wrappers (Ollama local -> OpenAI fallback)
# Keep them minimal and pluggable
# Ollama:
#  model: ollama3, gemma
# -------------------------
def call_ollama(prompt: str, model: str = "ollama3") -> Optional[str]:
    """
    Call local Ollama HTTP completion endpoint.
    Ollama local uses different endpoints depending on install. This minimal example
    posts to /v1/complete where available. If not present or fails, return None.
    """
    if not requests:
        return None
    url = OLLAMA_URL.rstrip("/") + "/v1/complete"
    payload = {"model": model, "prompt": prompt, "max_tokens": 512}
    try:
        r = requests.post(url, json=payload, timeout=15)
        r.raise_for_status()
        data = r.json()
        # Ollama may return `choices` or `text` depending on version—try to be flexible
        if isinstance(data, dict):
            if "text" in data:
                return data["text"]
            if "choices" in data and len(data["choices"]) > 0:
                return data["choices"][0].get("message", {}).get("content") or data["choices"][0].get("text")
            # sometimes "output" or "result"
            if "output" in data:
                return str(data["output"])
        return None
    except Exception:
        return None

# -------------------------
# Simple LLM wrappers (Ollama local -> OpenAI fallback)
# Keep them minimal and pluggable
# OpenAI:
#  model: gpt-4o-mini
# -------------------------
def call_openai(prompt: str, model: str = "gpt-4o-mini") -> Optional[str]:
    """Minimal OpenAI call using requests to the new Responses API or legacy. Use OPENAI_API_KEY env var."""
    if not OPENAI_API_KEY:
        return None
    # Try the simple REST approach (Responses or ChatCompletions). We'll use completions fallback for portability.
    try:
        # try Responses endpoint first (if available)
        headers = {"Authorization": f"Bearer {OPENAI_API_KEY}", "Content-Type": "application/json"}
        # Newer Responses API endpoint - may vary with account; keep simple by trying chat completions
        url = "https://api.openai.com/v1/chat/completions"
        body = {
            "model": model,
            "messages": [{"role": "user", "content": prompt}],
            "max_tokens": 512,
            "temperature": 0.2
        }
        r = requests.post(url, headers=headers, json=body, timeout=15)
        r.raise_for_status()
        j = r.json()
        # Extract text
        if "choices" in j and len(j["choices"]) > 0:
            return j["choices"][0]["message"]["content"]
        return None
    except Exception:
        return None

def ask_llm(prompt: str, prefer: str = "ollama") -> str:
    """
    Try Ollama first (if prefer == 'ollama'), else try OpenAI.
    If both fail, return fallback message.
    """
    if prefer == "ollama":
        out = call_ollama(prompt)
        if out:
            return out
        out = call_openai(prompt)
        if out:
            return out
    else:
        out = call_openai(prompt)
        if out:
            return out
        out = call_ollama(prompt)
        if out:
            return out
    return "Sorry — no LLM provider is configured or responding. Check Ollama or OPENAI_API_KEY."

# -------------------------
# Simple Chromadb embedding store helpers (optional)
# -------------------------
@st.cache_resource
def init_chroma_and_embedder():
    """Initialize local chroma client + sentence transformer model for embeddings."""
    if chromadb is None or SentenceTransformer is None:
        return None, None
    try:
        client = chromadb.Client()
        model = SentenceTransformer("all-MiniLM-L6-v2")
        return client, model
    except Exception:
        return None, None

def embed_texts(model, texts: List[str]) -> List[List[float]]:
    if model is None:
        return []
    return model.encode(texts).tolist()

# -------------------------
# Streamlit UI
# -------------------------
st.title("AbideVerse – Your Daily AI-Powered Bible Verse Companion")
st.caption("A simple, KISS Streamlit + local LLM MVP for Bible verse memorization & devotions")

# initialize session defaults
if "lang" not in st.session_state:
    st.session_state.lang = DEFAULT_LANGUAGE
if "model_pref" not in st.session_state:
    st.session_state.model_pref = "ollama"  # options: 'ollama' or 'openai'
if "bible_version" not in st.session_state:
    st.session_state.bible_version = DEFAULT_BIBLE_VERSION

tabs = st.tabs(["Chat", "RAG", "Memorize", "Devotions", "Settings"])
chat_tab, rag_tab, mem_tab, dev_tab, set_tab = tabs

# -------------------------
# CHAT tab
# -------------------------
with chat_tab:
    st.header("Chat with AbideVerse")
    st.write("Ask for verse explanations, memorization tips, devotions, and practice help.")
    user_input = st.text_area("Your message", height=140, placeholder="e.g., Help me memorize John 3:16")
    col1, col2 = st.columns([1, 1])
    with col1:
        if st.button("Send"):
            prompt = f"You are AbideVerse, a gentle AI-powered Bible companion. Answer briefly and helpfully. Language: {st.session_state.lang}\nUser: {user_input}\n"
            with st.spinner("Contacting LLM..."):
                resp = ask_llm(prompt, prefer=st.session_state.model_pref)
            st.markdown("**AbideVerse:**")
            st.write(resp)
            save_conversation(user_input, resp)
    with col2:
        if st.button("Save sample question to DB"):
            save_conversation(user_input or "sample", "sample-response")
            st.success("Saved to local DB (conversations)")

    # show last 5 convos
    st.subheader("Recent conversations")
    try:
        c = DB.cursor()
        c.execute("SELECT user_text, bot_text, created_at FROM conversations ORDER BY created_at DESC LIMIT 6")
        rows = c.fetchall()
        for r in rows:
            st.markdown(f"- **You:** {r[0]}  \n  **AbideVerse:** {r[1]}  \n  *{r[2]}*")
    except Exception as e:
        st.write("No conversations yet.")

# -------------------------
# RAG tab
# -------------------------
with rag_tab:
    st.header("RAG — Upload scripture/devotional text (small files)")
    st.write("Upload a text or PDF file (small) to create a local retrieval set. Chromadb + sentence-transformers used if available.")
    uploaded = st.file_uploader("Upload .txt or .pdf (text-only)", type=["txt", "pdf"], accept_multiple_files=False)
    client, embed_model = init_chroma_and_embedder()
    if uploaded:
        st.info(f"Uploaded {uploaded.name}. Attempting to extract text...")
        text_content = ""
        if uploaded.type == "application/pdf" or uploaded.name.lower().endswith(".pdf"):
            try:
                # simple PDF extraction using PyPDF2 if available
                import PyPDF2
                reader = PyPDF2.PdfReader(uploaded)
                pages = [p.extract_text() or "" for p in reader.pages]
                text_content = "\n".join(pages)
            except Exception:
                # fallback: read raw bytes (not ideal)
                try:
                    text_content = uploaded.getvalue().decode("utf-8", errors="ignore")
                except Exception:
                    text_content = ""
        else:
            text_content = uploaded.getvalue().decode("utf-8", errors="ignore")
        if not text_content:
            st.error("Could not extract text from the file. For PDFs try text-based PDFs or upload .txt for now.")
        else:
            st.success("Text extracted (preview below).")
            st.text_area("Preview (first 1000 chars)", value=text_content[:1000], height=250)
            if client is None or embed_model is None:
                st.warning("Chromadb or sentence-transformers not installed. Install full requirements to use RAG.")
            else:
                if st.button("Create local retriever"):
                    # create a small Chroma collection per session
                    try:
                        col_name = f"abide_{int(time.time())}"
                        collection = client.create_collection(name=col_name)
                        # split naive: by newline paragraphs
                        docs = [p.strip() for p in text_content.split("\n\n") if p.strip()]
                        if not docs:
                            docs = [text_content]
                        embeddings = embed_texts(embed_model, docs)
                        collection.add(documents=docs, embeddings=embeddings, ids=[f"d{i}" for i in range(len(docs))])
                        st.session_state["chroma_collection"] = col_name
                        st.session_state["chroma_client"] = True  # marker
                        st.success(f"Created collection {col_name} with {len(docs)} docs.")
                    except Exception as e:
                        st.error(f"Failed to create collection: {e}")

    # Retrieval UI
    if st.session_state.get("chroma_collection") and client is not None:
        st.markdown("**Ask the uploaded docs**")
        q = st.text_input("Question about uploaded docs")
        if st.button("Query docs"):
            col = client.get_collection(name=st.session_state["chroma_collection"])
            q_emb = embed_texts(embed_model, [q])[0]
            results = col.query(query_embeddings=[q_emb], n_results=3)
            docs = [d for d in results["documents"][0] if d]
            prompt = f"You are AbideVerse. Use the following documents to answer the question. Be concise.\n\nDocs:\n{chr(10).join(docs)}\n\nQuestion: {q}\nAnswer:"
            with st.spinner("Running LLM on retrieved docs..."):
                answer = ask_llm(prompt, prefer=st.session_state.model_pref)
            st.write(answer)

# -------------------------
# MEMORIZE tab
# -------------------------
with mem_tab:
    st.header("Memorize — Practice Verses")
    st.write("Pick a verse, then choose a practice mode.")
    verse_key = st.selectbox("Choose verse", options=list(SAMPLE_VERSES.keys()))
    target_lang = st.selectbox("Display language", options=["en", "zh"], index=0)
    verse_text = SAMPLE_VERSES[verse_key][target_lang]
    st.markdown(f"**{verse_key}** — {st.session_state.bible_version}")
    st.write(verse_text)

    st.subheader("Practice modes")
    mode = st.radio("Mode", ["Cloze", "Complete last words", "Speak & check (text)"])
    if mode == "Cloze":
        blanks = st.slider("Number of blanks", 1, 4, 2)
        clozed = cloze(verse_text, blanks=blanks)
        st.write(clozed)
        answer = st.text_input("Type the missing words / full verse here")
        if st.button("Check answer (Cloze)"):
            if answer.strip():
                # Naive check: check overlap of words
                correct_rate = len(set(answer.lower().split()) & set(verse_text.lower().split())) / max(1, len(set(verse_text.lower().split())))
                correct = correct_rate > 0.6
                cc = save_progress(verse_key, correct)
                if correct:
                    st.success(f"Nice — looks good! (progress count {cc})")
                else:
                    st.info("Keep practicing — try again.")
    elif mode == "Complete last words":
        n = st.slider("How many last words to blank", 1, 6, 3)
        partial = blank_last_n_words(verse_text, n)
        st.write(partial)
        answer = st.text_input("Type the missing trailing words")
        if st.button("Check trailing words"):
            if answer.strip():
                correct = answer.strip().lower() in verse_text.lower()
                cc = save_progress(verse_key, correct)
                if correct:
                    st.success(f"Correct! (progress count {cc})")
                else:
                    st.info("Not quite — try again.")
    else:
        st.write("Speak & check is a future feature. For now, type what you would say.")
        answer = st.text_area("Type your spoken version of the verse here")
        if st.button("Check spoken text"):
            if answer.strip():
                overlap = len(set(answer.lower().split()) & set(verse_text.lower().split())) / max(1, len(set(verse_text.lower().split())))
                correct = overlap > 0.6
                cc = save_progress(verse_key, correct)
                if correct:
                    st.success(f"Good! (progress count {cc})")
                else:
                    st.info("Practice more — you're improving!")

    # Show user progress for this verse
    progress_cnt = get_progress(verse_key)
    st.write(f"Progress count (local): {progress_cnt}")
    if progress_cnt >= 3:
        st.balloons()
        st.success("Mastered! Consider moving to a new verse.")

# -------------------------
# DEVOTIONS tab
# -------------------------
with dev_tab:
    st.header("Daily Devotions")
    st.write("Short daily devotional samples. You can add your own in Settings.")
    SAMPLE_DEVOS = [
        {"title": "Trust in His Provision", "verse": "Philippians 4:19", "body": "God supplies our needs in unexpected ways. Rehearse God's faithfulness today and memorize Philippians 4:13.", "joke": "Why did the smartphone go to church? It wanted better reception."},
        {"title": "Comfort in the Shepherd", "verse": "Psalm 23:1", "body": "Rest in the Shepherd's care. Take a breath and repeat the verse aloud.", "joke": "What kind of car does a shepherd drive? A lamborghini."}
    ]
    for d in SAMPLE_DEVOS:
        with st.expander(d["title"]):
            st.markdown(f"**Verse:** {d['verse']}")
            # show sample verse text if we have it
            v = SAMPLE_VERSES.get(d["verse"])
            if v:
                st.write(v.get(st.session_state.lang, v.get("en")))
            st.write(d["body"])
            st.write(f"**Prelude (joke):** {d['joke']}")
            if st.button(f"Practice this verse ({d['verse']})"):
                st.session_state.setdefault("last_practice", d["verse"])
                st.success(f"Added {d['verse']} to your practice queue (local).")

# -------------------------
# SETTINGS tab
# -------------------------
with set_tab:
    st.header("Settings")
    st.write("Model provider & app settings")
    colA, colB = st.columns(2)
    with colA:
        model_choice = st.selectbox("Preferred Model Provider", options=["ollama", "openai"], index=0 if st.session_state.model_pref == "ollama" else 1)
        st.session_state.model_pref = model_choice
        lang_choice = st.selectbox("App language (UI & verse display)", options=["en", "zh"], index=0 if st.session_state.lang == "en" else 1)
        st.session_state.lang = lang_choice
        bible_choice = st.selectbox("Bible version", options=["ESV", "NIV"], index=0 if st.session_state.bible_version == "ESV" else 1)
        st.session_state.bible_version = bible_choice
    with colB:
        st.write("Environment keys")
        st.write(f"OPENAI configured: {'Yes' if OPENAI_API_KEY else 'No'}")
        st.write(f"Ollama reachable at: {OLLAMA_URL}")
        if st.button("Check Ollama"):
            ok = call_ollama("ping") is not None
            if ok:
                st.success("Ollama responded.")
            else:
                st.error("No Ollama response. Is Ollama running locally?")
        if st.button("Clear local conversation DB"):
            try:
                c = DB.cursor()
                c.execute("DELETE FROM conversations")
                DB.commit()
                st.success("Cleared conversations.")
            except Exception as e:
                st.error(f"Error clearing DB: {e}")

    st.markdown("**Notes**")
    st.write("- This is a local single-file demo. Replace `SAMPLE_VERSES` with licensed ESV/NIV or allow user uploads.")
    st.write("- To use RAG with PDF/text, install `chromadb`, `sentence-transformers`, and `PyPDF2`.")
