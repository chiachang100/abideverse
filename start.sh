#!/usr/bin/env bash

# Exit immediately if ANY command in the script fails (returns a non-zero exit code).
set -e

export OLLAMA_LOG_LEVEL=error  # 'error', 'warn', 'info', 'debug'
unset OLLAMA_DEBUG

echo "Starting Ollama..."
ollama serve &

# Wait for Ollama to be ready
echo "Waiting for Ollama to be ready..."
until curl -s http://127.0.0.1:11434 > /dev/null; do
  sleep 1
done

echo "Pulling model tinyllama & llama3..."
ollama pull tinyllama
ollama pull llama3
echo "Models pulled successfully."

mkdir -p tmp

echo "Starting Streamlit..."
streamlit run src/app.py --server.port=8501 --server.address=0.0.0.0

# Keep container alive until both background processes stop
wait
