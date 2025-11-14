# abideverse
AbideVerse – Your Daily AI-Powered Bible Verse Companion.

## Environment Setup
1. Create pip Virtualenv:
- Install virtualenv
  - `pip install virtualenv`

1. Install dependencies:
- `mkdir abideverse`
- `cd abideverse`

1. Upgrade pip
- `python -m pip install --upgrade pip`

1. Create a Virtual Environment
- `python -m venv abideverse`

1. Upgrade pip
- `python -m pip install --upgrade pip`

1. Activate the Virtual Environment
- macOS/Linux: `abideverse/bin/activate`
- Windows: `abideverse\Scripts\activate`

1. Deactivate the Environment
- `deactivate`

1. Deactivate the Environment
- `deactivate`

### Install packages

1. Install Streamlit packages
- sqlite3 is already part of Python’s standard library.
- `pip install streamlit chromadb`
- `pip install sentence-transformers faiss-cpu pydantic fastapi`

1. Install LangChain packages
- `pip install langchain langchain-core langchain-community`
- `pip install langchain-google-genai langchain-anthropic langchain-ollama`
- `pip install langchain-text-splitters`

1. Install Ollama server
- `pip install ollama`

### Creating a requirements.txt file
- `pip freeze > requirements.txt`

### Install packages from a requirements file:
- `pip install -r requirements.txt`

---
## How to run `streamlit` and `ollama` locally
- On one terminal, run `ollama1`:
  - `ollama run llama3`
- On another terminal, run `streamlit`:
  - `cd abideverse`
  - `streamlit run app.py`

## How to run `streamlit` and `huggingface` remotely
- On one terminal, run `streamlit`:
  - `cd abideverse`
  - `streamlit run app.py`

---
## Use conda command
### Set up Python Environment
- `conda create --name abideverse python=3.11`
- `conda activate abideverse`
- `conda install numpy pandas scikit-learn -y`

## Logos Lamp App
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
