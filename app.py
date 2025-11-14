# app.py
import streamlit as st
import json
import sqlite3
import yaml

# --- LangChain v1.0+ imports ---
from langchain_community.chat_models import ChatOllama
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnableSequence
from langchain_core.output_parsers import StrOutputParser
from langchain_community.chat_message_histories import ChatMessageHistory

# --- Load configuration ---
with open("config.yaml") as f:
    config = yaml.safe_load(f)

# --- Load Bible verses ---
with open("bible_data/bible_verses.json") as f:
    verses = json.load(f)

# --- Setup database ---
conn = sqlite3.connect("db.sqlite")
c = conn.cursor()
c.execute("""
CREATE TABLE IF NOT EXISTS progress (
    user TEXT,
    verse_id INTEGER,
    correct INTEGER
)
""")
conn.commit()

# --- Setup LLM and memory ---

# Setup history
history = ChatMessageHistory()

# Add messages as user interacts
history.add_user_message("Hello!")
history.add_ai_message("Hi, how can I help?")

llm = ChatOllama(model=config["local_model"])

# Build prompt with history
prompt = ChatPromptTemplate.from_messages(
    [("system", "You are a helpful assistant for Bible verse memorization.")] +
    history.messages +  # inject past turns
    [("human", "{input}")]
)

# Build chain using LCEL (LangChain Expression Language)
chain = RunnableSequence(
    prompt | llm | StrOutputParser()
)

# --- Streamlit UI ---
st.title("AbideVerse – Your Daily AI-Powered Bible Verse Companion")

st.sidebar.header("User Settings")
user = st.sidebar.text_input("Your Name", "Guest")

# --- Verse Quiz Section ---
st.header("Verse Memorization Quiz")
verse = st.selectbox(
    "Choose a verse to memorize",
    [f"{v['book']} {v['chapter']}:{v['verse']}" for v in verses]
)
user_input = st.text_area("Enter your recall:")

if st.button("Check"):
    # Find selected verse text
    v_obj = next(v for v in verses if f"{v['book']} {v['chapter']}:{v['verse']}" == verse)
    # Call LLM for feedback
    feedback = chain.invoke({
        "input": f"Check this user recall for accuracy:\nVerse: {v_obj['text']}\nUser input: {user_input}"
    })
    st.write("**Feedback:**", feedback)
    # Store result in DB (simple example: correct if exact match)
    correct = int(user_input.strip() == v_obj['text'])
    c.execute("INSERT INTO progress (user, verse_id, correct) VALUES (?, ?, ?)", (user, verses.index(v_obj), correct))
    conn.commit()

# --- Memory Section ---
st.header("Conversation History")
st.text_area("Memory", value="\n".join([f"{m.type}: {m.content}" for m in history.messages]), height=200)