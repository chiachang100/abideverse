import streamlit as st
from models import load_llm
from chains import build_chat_chain, build_rag_chain, build_quiz_chain
from vectorstore import get_retriever, add_document
from utils import load_bible, cloze_text, translate_text
from storage import init_db, add_memory_card, get_cards

st.set_page_config(page_title="AbideVerse – Your Daily AI-Powered Bible Verse Companion")

init_db()

st.title("📖 AbideVerse")
st.subheader("Your Daily AI-Powered Bible Verse Companion")

# Settings Sidebar
st.sidebar.header("⚙️ Settings")
provider = st.sidebar.selectbox("LLM Provider", ["ollama", "openai", "huggingface", "gemini", "anthropic"],)
model_name = st.sidebar.selectbox("Model Name", ["llama3", "gpt-3.5-turbo", "google/flan-t5-small", "gemini-1.5-pro", "claude-3-opus"])
language = st.sidebar.selectbox("Language", ["English", "Chinese"])

llm = load_llm(provider, model_name)

tabs = st.tabs(["💬 Chat", "📚 RAG", "🧠 Memorize", "🌅 Devotions", "🔧 Settings"])

# ---------------- Chat Tab ----------------
with tabs[0]:
    st.subheader("Conversational Bible Chat")

    user_msg = st.text_input("Ask AbideVerse anything:")
    if st.button("Send") and user_msg:
        chat_chain = build_chat_chain(llm)
        response = chat_chain.invoke({"message": user_msg})
        st.write(response if language == "English" else translate_text(response, "zh"))

# ---------------- RAG Tab ----------------
with tabs[1]:
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
        st.write(answer if language == "English" else translate_text(answer, "zh"))

# ---------------- Memorize Tab ----------------
with tabs[2]:
    st.subheader("Bible Memorization")

    bible = load_bible()
    verse = st.selectbox("Choose a verse:", list(bible.values()))
    if st.button("Generate Cloze Quiz"):
        cloze = cloze_text(verse)
        add_memory_card(verse, cloze)
        st.code(cloze)

    st.write("📘 Saved Memory Cards:")
    for card in get_cards():
        st.write(f"- {card[2]}")

# ---------------- Devotions Tab ----------------
with tabs[3]:
    st.subheader("Daily Devotion (AI Generated)")
    verse = st.text_input("Enter a verse to reflect on:")
    if st.button("Generate Devotion"):
        chain = build_chat_chain(llm)
        prompt = f"Create a short devotion based on this verse: {verse}"
        text = chain.invoke({"message": prompt})
        st.write(text)

# ---------------- Settings Tab ----------------
with tabs[4]:
    st.subheader("App Settings")
    st.write("Change provider, language, and model from the sidebar.")
