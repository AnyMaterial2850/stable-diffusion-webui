FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    git git-lfs ffmpeg libgl1 libstdc++6 curl && \
    git lfs install && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN git clone --depth=1 https://github.com/AUTOMATIC1111/stable-diffusion-webui /app/webui

# persistent dirs (we’ll mount a Railway Volume at /data later)
RUN mkdir -p /data/models/Stable-diffusion /data/models/Lora /data/embeddings \
 && ln -s /data/models/Stable-diffusion /app/webui/models/Stable-diffusion \
 && ln -s /data/models/Lora /app/webui/models/Lora \
 && ln -s /data/embeddings /app/webui/embeddings

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
      torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu && \
    pip install --no-cache-dir -r /app/webui/requirements_versions.txt

ENV PORT=7860
WORKDIR /app/webui
CMD bash -lc 'python launch.py --listen --port ${PORT:-7860} --api'
