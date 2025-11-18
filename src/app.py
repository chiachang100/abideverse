
import streamlit as st
import time
import datetime
import os

from models import load_llm
from chains import build_chat_chain, build_rag_chain, build_quiz_chain
from vectorstore import get_retriever, add_document
from utils import load_bible, cloze_text, translate_text
from storage import init_db, add_memory_card, get_cards

# App Title
st.title("AbideVerse ✝️🌿")
st.markdown("*Your Daily AI-Powered Bible Verse Companion*")

st.set_page_config(page_title="AbideVerse – Your Daily AI-Powered Bible Verse Companion")

# -------- Helper: Initialize the storage --------
init_db()

if "first_load" not in st.session_state:
    st.session_state.first_load = True

# Initialize session state
if "last_provider" not in st.session_state:
    st.session_state.last_provider = None
if "last_model" not in st.session_state:
    st.session_state.last_model = None

# Track active tab in session state (default = first tab)
if "active_tab" not in st.session_state:
    st.session_state.active_tab = "💬 Chat"   # default

if st.session_state.first_load:
    st.markdown("### ✝️🌿 Welcome to AbideVerse")
    #st.markdown("> *May this space be a place of abiding.*\n> *May wisdom flow, and light be kindled.*\n> *May every verse be a vine, and every word bear fruit.*")
    st.markdown("> ✝️ *“Abide in me, and I in you. As the branch cannot bear fruit by itself, unless it abides in the vine, neither can you, unless you abide in me.” (John 15:4, ESV)*")
    st.markdown("---")
    st.session_state.first_load = False

# -------- Helper: Translation wrapper --------
def maybe_translate(text):
    lang_map = {
        "English": "en",
        "Traditional Chinese": "zh-TW",
        "Simplified Chinese": "zh-CN"
    }
    return translate_text(text, lang_map.get(language)) if language != "English" else text

# ---------------- Sidebar Settings ----------------
st.sidebar.header("⚙️ Settings")

# Step 1: Provider selection
#provider = st.sidebar.selectbox("LLM Provider", ["ollama", "huggingface", "openai", "gemini", "anthropic"],)
provider = st.sidebar.selectbox("🧠 LLM Provider", ["ollama"])

# Step 2: Dynamically show model options based on provider
if provider == "ollama":
    model_name = st.sidebar.selectbox("🪶 Ollama Model", ["tinyllama", "llama3"])
elif provider == "huggingface":
    model_name = st.sidebar.selectbox("🧬 Hugging Face Model", 
                                      [
                                          "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
                                          "Qwen/Qwen1.5-1.8B-Chat",
                                          "mistralai/Mistral-7B-Instruct",
                                          "microsoft/Phi-3-medium-4k-instruct",
                                          "google/gemma-2-9b-it",
                                          "tiiuae/falcon-rw-1b",
                                          "google/flan-t5-small"
                                       ])
elif provider == "openai":
    model_name = st.sidebar.selectbox("🌐 OpenAI Model", ["gpt-3.5-turbo", "gpt-4"])
elif provider == "gemini":
    model_name = st.sidebar.selectbox("🌐 OpenAI Model", ["gemini-1.5-pro"])
elif provider == "anthropic":
    model_name = st.sidebar.selectbox("🌐 OpenAI Model", ["claude-3-opus"])
else:
    model_name = None  # fallback

language = st.sidebar.selectbox("Language", ["English", "Traditional Chinese", "Simplified Chinese"])

# --- Detect change and clear cache ---
if provider != st.session_state.last_provider or model_name != st.session_state.last_model:
    st.cache_resource.clear()
    st.session_state.last_provider = provider
    st.session_state.last_model = model_name


# ======================================================
# ---------------- Main LLMs start here ----------------
# ======================================================

# Display the selections
st.markdown(f"**Provider:** {provider} | **Model:** {model_name} | **Language:** {language}")

llm = load_llm(provider, model_name)

# ----------------------------------------------
# ---------------- Tab Handlers ----------------
# ----------------------------------------------

# ---------------- Chat starts here ----------------
def chat_tab():
    st.subheader("Conversational Bible Chat")
    user_msg = st.text_input("Ask AbideVerse anything:")

    if st.button("Send") and user_msg:
        chat_chain = build_chat_chain(llm)
        response = chat_chain.invoke({"message": user_msg})
        st.write(maybe_translate(response))

# ---------------- RAG Bible Q&A starts here ----------------
def rag_tab():
    st.subheader("RAG Bible Q&A")
    doc = st.text_area("Paste Bible notes or devotional text to index:")

    if st.button("Add to RAG Store"):
        add_document(doc)
        st.success("Added to vectorstore!")

    question = st.text_input("Ask a question from your documents:")
    if st.button("RAG Search"):
        retriever = get_retriever(provider)
        rag_chain = build_rag_chain(llm, retriever)
        answer = rag_chain.invoke(question)
        st.write(maybe_translate(answer))

# ---------------- Bible Memorization starts here ----------------
def memorize_tab():
    st.subheader("Bible Memorization")

    bible = load_bible()
    verse = st.selectbox("Choose a verse:", list(bible.values()))

    if st.button("Generate Cloze Quiz"):
        cloze = cloze_text(verse)
        add_memory_card(verse, cloze)
        st.cache_data.clear()  # Clear cache so new card shows up
        st.code(cloze)

    st.write("📘 Saved Memory Cards:")
    for card in get_cards():
        st.write(f"- {card[2]}")

# ---------------- Daily Devotion (AI Generated) starts here ----------------
def devotion_tab():
    st.subheader("Daily Devotion (AI Generated)")
    verse = st.text_input("Enter a verse to reflect on:")

    if st.button("Generate Devotion"):
        chain = build_chat_chain(llm)
        prompt = f"Create a short devotion based on this verse: {verse}"
        text = chain.invoke({"message": prompt})
        st.write(maybe_translate(text))

# ---------------- joyolord starts here ----------------
def joyolord_tab():
    st.subheader("主的喜樂 | 笑裡藏道")
    st.markdown("[啟動「主的喜樂 | 笑裡藏道」App (Launch Joyolord App)](https://joyolordapp.web.app/)")

# ---------------- ✝️🪔🌿 Spiritual Prep starts here ----------------
def spiritual_prep_tab():
    st.subheader("Spiritual Prep ✝️🌿")
    st.markdown("🌿 *Prepare AbideVerse for a spiritually and technically ready experience.*")

    st.markdown("✝️ **“Abide in me, and I in you…” (John 15:4, ESV)**")
    st.markdown("---")

    if st.button("🔥 Warm Cache"):
        _ = load_llm(provider, model_name)
        _ = build_chat_chain(load_llm(provider, model_name))
        _ = load_bible()
        st.success("Cache warmed!")

    if st.button("🧪 Test Response"):
        try:
            start = time.time()
            llm_instance = load_llm(provider, model_name)
            test_chain = build_chat_chain(llm_instance)
            test_prompt = "Summarize John 1:1 in one sentence."
            test_output = test_chain.invoke({"message": test_prompt})
            duration = time.time() - start
            st.markdown("**Test Output:**")
            st.write(maybe_translate(test_output))
            st.markdown(f"**⏱️ Response Time:** {duration:.2f} seconds")
            st.markdown(f"**🔍 Model Used:** `{provider}` – `{model_name}`")
        except Exception as e:
            st.error(f"Test failed: {e}")

    if st.button("📖 Preload Verse"):
        try:
            bible = load_bible()
            preload_key = "John 1:1"
            preload_verse = bible.get(preload_key, "In the beginning was the Word...")
            cloze = cloze_text(preload_verse)
            add_memory_card(preload_verse, cloze)
            st.cache_data.clear()
            st.success(f"Preloaded verse: {preload_key}")
            st.code(cloze)
        except Exception as e:
            st.error(f"Preload failed: {e}")

    if st.button("🧹 Clear Cache"):
        st.cache_data.clear()
        st.cache_resource.clear()
        st.session_state["last_cache_clear"] = f"🕒 Cleared at {time.strftime('%H:%M:%S')}"
        st.session_state["first_load"] = True
        st.success("Cache cleared!")

    if "last_cache_clear" in st.session_state:
        st.markdown(st.session_state["last_cache_clear"])

# ---------------- Settings starts here ----------------
def settings_tab():
    st.subheader("App Settings")
    st.markdown("Global app configuration is managed in the sidebar.")
    st.markdown("""
    - 🧠 LLM Provider  
    - 🪶 Model  
    - 🌐 Language / translation  
    - ⚙️ Theme & layout (future)
    """)

# ---------------- Tab Registry ----------------
tabs_config = [
    ("💬 Chat", chat_tab),
    ("📚 RAG", rag_tab),
    ("🧠 Memorize", memorize_tab),
    ("🌅 Devotions", devotion_tab),
    ("😊 主的喜樂", joyolord_tab),
    ("🕊️ Spiritual Prep", spiritual_prep_tab),   # NEW
    ("🔧 App Setting", settings_tab),
]


# ---------------- Tab Rendering ----------------
tab_labels = [label for label, _ in tabs_config]
tab_objects = st.tabs(tab_labels)

for tab_obj, (label, handler) in zip(tab_objects, tabs_config):
    with tab_obj:
        handler()  # render each tab
