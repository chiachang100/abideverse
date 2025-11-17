from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableParallel, RunnablePassthrough
import streamlit as st

@st.cache_resource
def build_chat_chain(llm):
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are AbideVerse, an AI companion helping with devotion and Bible study."),
        ("human", "{message}")
    ])

    return prompt | llm | StrOutputParser()


@st.cache_resource
def build_rag_chain(llm, retriever):
    system_prompt = """
You are AbideVerse RAG Assistant. Use ONLY the provided context to answer questions biblically.
If the answer is not present, say so.

CONTEXT:
{context}
"""

    prompt = ChatPromptTemplate.from_messages([
        ("system", system_prompt),
        ("human", "{question}")
    ])

    rag_chain = (
        RunnableParallel({
            "context": retriever,
            "question": RunnablePassthrough()
        })
        | prompt
        | llm
        | StrOutputParser()
    )

    return rag_chain


@st.cache_resource
def build_quiz_chain(llm):
    prompt = ChatPromptTemplate.from_messages([
        ("system", "Generate a Bible verse memorization quiz (cloze)."),
        ("human", "Verse: {verse}")
    ])

    return prompt | llm | StrOutputParser()
