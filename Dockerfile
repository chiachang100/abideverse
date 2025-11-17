# Start with a stable base image
FROM python:3.12-slim

# Create working directory
WORKDIR /app

# Install system dependencies
# curl     → needed to install Ollama
# bash     → required for entrypoint script
# libc6, libgomp1 → needed by ollama to run
RUN apt-get update && apt-get install -y \
    build-essential \
    curl bash \
    git \
    libgomp1 libc6 \
    && rm -rf /var/lib/apt/lists/*

# Install Ollama inside the container
RUN curl -fsSL https://ollama.com/install.sh | bash

# Install Python dependencies
COPY requirements.txt ./
COPY src/ ./src/

RUN pip install --no-cache-dir -r requirements.txt

# Copy entrypoint script & make executable
COPY start.sh ./
RUN chmod +x ./start.sh

# Expose ports for both services
# Streamlit: 8501
# Ollama API: 11434
EXPOSE 8501
EXPOSE 11434

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health

# Start both services
ENTRYPOINT ["./start.sh"]
