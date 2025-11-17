---
title: AbideVerse
emoji: 🚀
colorFrom: indigo
colorTo: blue
sdk: docker
app_port: 8501
tags:
  - streamlit
pinned: false
short_description: AbideVerse – Your Daily AI-Powered Bible Verse Companion.
license: apache-2.0
---

# abideverse
AbideVerse – Your Daily AI-Powered Bible Verse Companion.

**NOTE**: This is a custom Docker-based Streamlit application deployed to Hugging Face Spaces.

## Environment Setup
1. Download and install Python (v3.12)
- [Python Download](https://www.python.org/downloads/)

1. Create pip Virtualenv:
- Install virtualenv
  - `pip install virtualenv`

1. Install dependencies:
- `mkdir abideverse`
- `cd abideverse`

1. Upgrade pip
- `python -m pip install --upgrade pip`

1. Create a Virtual Environment
- `python -m venv .venv`

1. Upgrade pip
- `python -m pip install --upgrade pip`

1. Activate the Virtual Environment
- macOS/Linux: `.venv/bin/activate`
- Windows: `.venv\Scripts\activate`

1. Deactivate the Environment
- `deactivate`

1. Deactivate the Environment
- `deactivate`

### Install packages

1. Install Streamlit packages
- sqlite3 is already part of Python’s standard library.
- `pip install streamlit`
- `pip install sentence-transformers faiss-cpu pydantic fastapi`

1. Install LangChain packages
- `pip install langchain langchain-core langchain-community`
- `pip install langchain-chroma`
- `pip install langchain-google-genai langchain-anthropic langchain-ollama`
- `pip install langchain-text-splitters`

1. Install Ollama server
- `pip install ollama`

1. Install Miscellaneous packages
- Packages: `numpy`, `panda`

- `pip install plotly`

---
### Creating a requirements.txt file
- `pip freeze > requirements.txt`

### Install packages from a requirements file:
- `pip install -r requirements.txt`
- `python.exe -m pip install --upgrade pip`

---
## How to run `streamlit` and `ollama` locally
- On one terminal, run `ollama`:
  - Use `TinyLlama` (700MB) instead of `llama3` is large (GB)
  - `ollama run tinyllama`
- On another terminal, run `streamlit`:
  - `cd abideverse`
  - macOS/Linux: `.venv/bin/activate`
  - Windows: `.venv\Scripts\activate`
  - `streamlit run app.py`

### Hosting AbideVerse on Streamlit Community Cloud
- Deploy AbideVerse from Github repo to Streamlit Community Cloud
  - URL: [https://abideverse.streamlit.app/](https://abideverse.streamlit.app/)

---
## Use `conda` command
### Set up Python Environment
- `conda create --name abideverse python=3.11`
- `conda activate abideverse`
- `conda install numpy pandas scikit-learn -y`

## AbideVerse App
- built for LangChain 1.0+, Streamlit, Ollama (local LLM), FAISS, and optional Gemini / Claude cloud backends.

### Install Agentic AI/GenAI packages
- `pip install streamlit fastapi langchain ollama sentence-transformers faiss-cpu pydantic openai crewai`

- `conda install pytorch torchvision torchaudio pytorch-cuda=11.8 -c pytorch -c nvidia`

### Export the environment for reproducibility (environment.abideverse.yml)
- `conda env export > environment.abideverse.yml`

### Share and recreate the environment
- `conda env create -f environment.abideverse.yml`
- `conda activate abideverse`

---
