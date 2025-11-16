import os
from langchain_community.vectorstores import Chroma
from models import load_embeddings

CHROMA_DIR = "tmp/chroma_store"

def load_vectorstore(provider="ollama", embeddings_model="llama3"):
    embeddings = load_embeddings(provider, embeddings_model)

    if not os.path.exists(CHROMA_DIR):
        os.makedirs(CHROMA_DIR)

    return Chroma(persist_directory=CHROMA_DIR, embedding_function=embeddings)


def get_retriever(provider="ollama", embeddings_model="llama3"):
    vs = load_vectorstore(provider, embeddings_model)
    return vs.as_retriever(search_type="similarity", search_kwargs={"k": 3})


def add_document(text, metadata=None, provider="ollama", embeddings_model="llama3"):
    vs = load_vectorstore(provider, embeddings_model)
    vs.add_texts([text], metadatas=[metadata or {}])
    vs.persist()
