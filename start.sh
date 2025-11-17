#!/usr/bin/env bash

# Exit immediately if ANY command in the script fails (returns a non-zero exit code).
set -e

echo "Starting Ollama..."
ollama serve &

# Optional: preload a model (uncomment if needed)
echo "Pulling model llama3..."
ollama pull llama3

mkdir tmp

echo "Starting Streamlit..."
streamlit run src/app.py --server.port=8501 --server.address=0.0.0.0

# Keep container alive until both background processes stop
Wait
