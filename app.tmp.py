import streamlit as st
import json
import sqlite3
import yaml


from langchain_community.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

# --- LangChain v1.0+ imports ---
from langchain_core.runnables import RunnableSequence
from langchain_core.output_parsers import StrOutputParser
from langchain_community.chat_message_histories import ChatMessageHistory

# Chat models
from langchain_community.chat_models import ChatOllama
# Prompts
from langchain_core.prompts import ChatPromptTemplate
# Embeddings and vector DB
from langchain_community.embeddings import SentenceTransformerEmbeddings
from langchain_community.vectorstores import FAISS
# Text splitting
from langchain_text_splitters import RecursiveCharacterTextSplitter
# Documents
#from langchain_core.docstore.document import Document
# Document
from langchain_core.documents import Document


# Load prompt template
with open("prompts/bible_prompt.txt", "r") as f:
    prompt_template_str = f.read()

prompt = PromptTemplate(
    input_variables=["action", "verse_reference", "translation"],
    template=prompt_template_str
)

# Ollama LLM
llm = Ollama(model="llama3")  # replace with local Ollama model
chain = LLMChain(llm=llm, prompt=prompt)

st.title("AbideVerse – Your Daily AI-Powered Bible Verse Companion")

action = st.radio("Select action", ["memorize", "devotion"])
verse_ref = st.text_input("Enter Bible verse (e.g., John 3:16)")
translation = st.text_input("Translation (default: ESV)", value="ESV")

if st.button("Generate"):
    if verse_ref.strip() == "":
        st.warning("Please enter a verse reference")
    else:
        result = chain.run(
            action=action,
            verse_reference=verse_ref,
            translation=translation
        )
        try:
            data = json.loads(result)
            st.subheader("Verse")
            st.write(data["verse"])
            st.subheader("Reference")
            st.write(data["reference"])
            if action == "memorize":
                st.subheader("Memorization Tip")
                st.write(data.get("memorization_tip", ""))
                st.subheader("Quiz Question")
                st.write(data.get("quiz_question", ""))
            st.subheader("Reflection")
            st.write(data.get("reflection", ""))
        except Exception as e:
            st.error(f"Error parsing AI response: {e}")
