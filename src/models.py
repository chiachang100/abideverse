import os
from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_ollama import ChatOllama, OllamaEmbeddings
from langchain_huggingface import HuggingFaceEndpoint, HuggingFaceEmbeddings
from langchain_google_genai import ChatGoogleGenerativeAI, GoogleGenerativeAIEmbeddings
from langchain_anthropic import ChatAnthropic
import streamlit as st


@st.cache_resource
def load_llm(provider: str = "ollama", model: str = "llama3"):
    """
    Supported providers:
    - ollama (local, free)
    - openai
    - huggingface
    """
    provider = provider.lower()

    if provider == "ollama":
        return ChatOllama(model=model)
    elif provider == "openai":
        return ChatOpenAI(
            model=model,
            temperature=0.2
        )
    elif provider == "huggingface":
        return HuggingFaceEndpoint(
            repo_id=model,
            temperature=0.2
        )
    elif provider == "gemini":
        return ChatGoogleGenerativeAI(
            model=model,
            temperature=0.2
        )
    elif provider == "anthropic":
        """anthropic-claude"""
        return ChatAnthropic(
            model=model,
            temperature=0.2
        )
    else:
        raise ValueError(f"Unknown provider: {provider}")


def load_embeddings(provider: str = "ollama", model: str = "llama3"):
    provider = provider.lower()

    if provider == "ollama":
        return OllamaEmbeddings(model=model)
    elif provider == "openai":
        return OpenAIEmbeddings(model="text-embedding-3-small")
    elif provider == "huggingface":
        return HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    elif provider == "gemini":
        return GoogleGenerativeAIEmbeddings(model="models/embedding-001")
    elif provider == "anthropic":
        # Anthropic doesn't have Embeddings model, use HF's
        return HuggingFaceEmbeddings(model_name="sentence-transformers/all-MiniLM-L6-v2")
    else:
        raise ValueError(f"Unknown embedding provider: {provider}")
