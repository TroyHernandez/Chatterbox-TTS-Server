# syntax=docker/dockerfile:1.7
FROM nvidia/cuda:12.8.1-runtime-ubuntu22.04

ARG RUNTIME=nvidia  # set to "cpu" to build CPU image
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    HF_HOME=/app/hf_cache \
    TORCH_HOME=/app/torch_cache \
    OMP_NUM_THREADS=1 \
    MKL_NUM_THREADS=1

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
      python3 python3-pip python3-dev python3-venv \
      git ffmpeg libsndfile1 build-essential ca-certificates curl \
    && rm -rf /var/lib/apt/lists/* \
    && ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /app

# Hugging Face / Torch caches live in one place we can mount
ENV HF_HOME=/opt/app/hf_cache \
    HUGGINGFACE_HUB_CACHE=/opt/app/hf_cache \
    TRANSFORMERS_CACHE=/opt/app/hf_cache \
    XDG_CACHE_HOME=/opt/app/.cache \
    TORCH_HOME=/opt/app/.cache/torch

# Make sure the dirs exist and are writable even with host-mounted volumes
RUN mkdir -p /opt/app/hf_cache /opt/app/.cache/torch /opt/app/outputs \
 && chmod -R 777 /opt/app
 
# Copy both requirement sets
COPY requirements.txt requirements.txt
COPY requirements-nvidia.txt requirements-nvidia.txt

# Upgrade pip & install ONE requirements file (GPU or CPU)
RUN python -m pip install --upgrade pip setuptools wheel && \
    if [ "$RUNTIME" = "nvidia" ]; then \
        echo "Installing GPU deps from requirements-nvidia.txt" && \
        pip install --no-cache-dir -r requirements-nvidia.txt ; \
    else \
        echo "Installing CPU deps from requirements.txt" && \
        pip install --no-cache-dir -r requirements.txt ; \
    fi

# App code
COPY . .

# Ensure expected dirs exist
RUN mkdir -p model_cache reference_audio outputs voices logs hf_cache torch_cache

EXPOSE 8004
CMD ["python", "server.py"]
