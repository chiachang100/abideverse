
import streamlit as st
from models import load_llm
from chains import build_chat_chain, build_rag_chain, build_quiz_chain
from vectorstore import get_retriever, add_document
from utils import load_bible, cloze_text, translate_text
from storage import init_db, add_memory_card, get_cards

st.set_page_config(page_title="AbideVerse – Your Daily AI-Powered Bible Verse Companion")

init_db()

# App Title
st.title("📖 AbideVerse")
st.markdown("*Your Daily AI-Powered Bible Verse Companion*")

# ---------------- Sidebar Settings ----------------
st.sidebar.header("⚙️ Settings")

#provider = st.sidebar.selectbox("LLM Provider", ["ollama", "openai", "huggingface", "gemini", "anthropic"],)
#model_name = st.sidebar.selectbox("Model Name", ["llama3", "gpt-3.5-turbo", "google/flan-t5-small", "gemini-1.5-pro", "claude-3-opus"])

provider = st.sidebar.selectbox("LLM Provider", ["ollama", "openai"])
model_name = st.sidebar.selectbox("Model Name", ["llama3", "gpt-3.5-turbo"])
language = st.sidebar.selectbox("Language", ["English", "Traditional Chinese", "Simplified Chinese"])

llm = load_llm(provider, model_name)

# -------- Helper: Translation wrapper --------
def maybe_translate(text):
    lang_map = {
        "English": "en",
        "Traditional Chinese": "zh-TW",
        "Simplified Chinese": "zh-CN"
    }
    return translate_text(text, lang_map.get(language)) if language != "English" else text

# ---------------- Tab Handlers ----------------
def chat_tab():
    st.subheader("Conversational Bible Chat")
    user_msg = st.text_input("Ask AbideVerse anything:")

    if st.button("Send") and user_msg:
        chat_chain = build_chat_chain(llm)
        response = chat_chain.invoke({"message": user_msg})
        st.write(maybe_translate(response))

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

def devotion_tab():
    st.subheader("Daily Devotion (AI Generated)")
    verse = st.text_input("Enter a verse to reflect on:")

    if st.button("Generate Devotion"):
        chain = build_chat_chain(llm)
        prompt = f"Create a short devotion based on this verse: {verse}"
        text = chain.invoke({"message": prompt})
        st.write(maybe_translate(text))

def joyolord_tab():
    st.subheader("主的喜樂 | 笑裡藏道")
    st.markdown("[啟動「主的喜樂 | 笑裡藏道」App (Launch Joyolord App)](https://joyolordapp.web.app/)")

def settings_tab():
    st.subheader("App Settings")
    st.write("Change provider, language, and model from the sidebar.")

# ---------------- Tab Registry ----------------
tabs_config = [
    ("💬 Chat", chat_tab),
    ("📚 RAG", rag_tab),
    ("🧠 Memorize", memorize_tab),
    ("🌅 Devotions", devotion_tab),
    ("😊 主的喜樂", joyolord_tab),
    ("🔧 Settings", settings_tab),
]

# Create tabs
tab_labels = [label for label, _ in tabs_config]
tab_objects = st.tabs(tab_labels)

# Render tabs via loop
for tab, (_, handler) in zip(tab_objects, tabs_config):
    with tab:
        handler()
