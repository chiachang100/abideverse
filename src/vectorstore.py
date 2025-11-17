import os
from langchain_chroma import Chroma
from models import load_embeddings
import streamlit as st

CHROMA_DIR = "tmp/chroma_store"

def load_vectorstore(provider="ollama", embeddings_model="tinyllama"):
    """
    Load the Chroma vectorstore with the specified embeddings.
    Automatically creates the persistence directory if it doesn't exist.
    """
    embeddings = load_embeddings(provider, embeddings_model)

    os.makedirs(CHROMA_DIR, exist_ok=True)

    return Chroma(
        persist_directory=CHROMA_DIR,
        embedding_function=embeddings
    )


@st.cache_resource
def get_retriever(provider="ollama", embeddings_model="tinyllama"):
    """
    Get a retriever for the vectorstore. Uses similarity search by default.
    """
    vs = load_vectorstore(provider, embeddings_model)
    return vs.as_retriever(search_type="similarity", search_kwargs={"k": 3})


def add_document(text, metadata=None, provider="ollama", embeddings_model="tinyllama"):
    """
    Add a single document to the vectorstore.
    Automatic persistence is handled by Chroma; no need to call vs.persist().
    """
    vs = load_vectorstore(provider, embeddings_model)
    vs.add_texts([text], metadatas=[metadata or {}])
