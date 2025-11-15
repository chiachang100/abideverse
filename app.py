import streamlit as st
from models import load_llm
from chains import build_chat_chain, build_rag_chain, build_quiz_chain
from vectorstore import get_retriever, add_document
from utils import load_bible, cloze_text, translate_text
from storage import init_db, add_memory_card, get_cards

st.set_page_config(page_title="AbideVerse – Your Daily AI-Powered Bible Verse Companion")

init_db()

st.title("📖 AbideVerse")
#st.subheader("Your Daily AI-Powered Bible Verse Companion")
st.markdown("*Your Daily AI-Powered Bible Verse Companion*")

# Settings Sidebar
st.sidebar.header("⚙️ Settings")

#provider = st.sidebar.selectbox("LLM Provider", ["ollama", "openai", "huggingface", "gemini", "anthropic"],)
#model_name = st.sidebar.selectbox("Model Name", ["llama3", "gpt-3.5-turbo", "google/flan-t5-small", "gemini-1.5-pro", "claude-3-opus"])
provider = st.sidebar.selectbox("LLM Provider", ["ollama", "openai"],)
model_name = st.sidebar.selectbox("Model Name", ["llama3", "gpt-3.5-turbo"])

language = st.sidebar.selectbox("Language", ["English", "Simplified Chinese", "Traditional Chinese"])

llm = load_llm(provider, model_name)

tabs = st.tabs(["💬 Chat", "📚 RAG", "🧠 Memorize", "🌅 Devotions", "😊 笑裡藏道", "🔧 Settings"])

# ---------------- Chat Tab ----------------
with tabs[0]:
    st.subheader("Conversational Bible Chat")

    user_msg = st.text_input("Ask AbideVerse anything:")
    if st.button("Send") and user_msg:
        chat_chain = build_chat_chain(llm)
        response = chat_chain.invoke({"message": user_msg})

        if language == "English":
            translated_response = response
        elif language == "Simplified Chinese":
            translated_response = translate_text(response, "zh-CN")
        elif language == "Traditional Chinese":
            translated_response = translate_text(response, "zh-TW")
        else:
            translated_response = response

        st.write(translated_response)

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

# ---------------- 笑裡藏道-XLCD Tab ----------------
with tabs[4]:
    st.subheader("笑裡藏道|主的喜樂")
    st.markdown("[啟動 笑裡藏道|主的喜樂 App (Launch XLCD|Joyolord App)](https://joyolordapp.web.app/)")

# ---------------- Settings Tab ----------------
with tabs[5]:
    st.subheader("App Settings")
    st.write("Change provider, language, and model from the sidebar.")
