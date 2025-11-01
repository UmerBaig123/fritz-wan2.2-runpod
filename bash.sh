#!/bin/bash

# ComfyUI Setup Script - Single command to install everything
# Usage: ./bash.sh

set -e  # Exit on any error

echo "🚀 Starting ComfyUI WAN2.2 Setup..."

# Set environment variables
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True
export CUDA_VISIBLE_DEVICES=0
export PYTHONUNBUFFERED=1

# Change to root directory
cd /root

echo "📦 Installing system dependencies..."
apt-get update && apt-get install -y \
    git \
    ffmpeg \
    libsm6 \
    libxext6 \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

echo "🐍 Installing Python dependencies..."
pip install --no-cache-dir \
    "fastapi[standard]==0.115.4" \
    comfy-cli

echo "⚡ Installing ComfyUI with fast dependencies and NVIDIA support..."
comfy --skip-prompt install --fast-deps --nvidia

echo "🔧 Cloning custom nodes..."
cd /root/comfy/ComfyUI/custom_nodes && \
    git clone https://github.com/kijai/ComfyUI-GIMM-VFI.git && \
    git clone https://github.com/yolain/ComfyUI-Easy-Use.git && \
    git clone https://github.com/kijai/ComfyUI-KJNodes.git && \
    git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git && \
    git clone https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git && \
    git clone https://github.com/sipherxyz/comfyui-art-venture.git && \
    git clone https://github.com/chrisgoringe/cg-use-everywhere.git && \
    git clone https://github.com/Smirnov75/ComfyUI-mxToolkit.git && \
    git clone https://github.com/alt-key-project/comfyui-dream-video-batches.git && \
    git clone https://github.com/ciga2011/ComfyUI-MarkItDown.git && \
    git clone https://github.com/cubiq/ComfyUI_essentials.git && \
    git clone https://github.com/calcuis/gguf.git && \
    git clone https://github.com/rgthree/rgthree-comfy.git && \
    git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git && \
    git clone https://github.com/storyicon/comfyui_segment_anything.git && \
    git clone https://github.com/WASasquatch/was-node-suite-comfyui.git && \
    git clone https://github.com/chflame163/ComfyUI_LayerStyle.git && \
    git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git && \
    git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git && \
    git clone https://github.com/pydn/ComfyUI-to-Python-Extension.git

echo "📋 Installing requirements for custom nodes..."
cd /root/comfy/ComfyUI/custom_nodes && \
    for dir in ComfyUI-GIMM-VFI ComfyUI-Easy-Use ComfyUI-KJNodes ComfyUI-VideoHelperSuite \
               comfyui-art-venture comfyui-dream-video-batches ComfyUI-MarkItDown \
               ComfyUI_essentials rgthree-comfy ComfyUI-WanVideoWrapper comfyui_segment_anything \
               was-node-suite-comfyui ComfyUI_LayerStyle comfyui_controlnet_aux \
               ComfyUI-to-Python-Extension; do \
        if [ -f "$dir/requirements.txt" ]; then \
            echo "Installing requirements for $dir" && \
            pip install --no-cache-dir -r "$dir/requirements.txt" || echo "Failed to install requirements for $dir"; \
        else \
            echo "No requirements.txt found for $dir"; \
        fi; \
    done

echo "🔥 Installing additional dependencies..."
pip install --no-cache-dir onnxruntime-gpu onnx

echo "📁 Creating model directories..."
mkdir -p /root/comfy/ComfyUI/models/diffusion_models && \
    mkdir -p /root/comfy/ComfyUI/models/loras && \
    mkdir -p /root/comfy/ComfyUI/models/vae && \
    mkdir -p /root/comfy/ComfyUI/models/clip_vision && \
    mkdir -p /root/comfy/ComfyUI/models/clip && \
    mkdir -p /root/comfy/ComfyUI/input && \
    mkdir -p /root/comfy/ComfyUI/output

echo "⬇️ Downloading models (this will take a while)..."
cd /root/comfy/ComfyUI/models

echo "  📥 Downloading diffusion models..."
wget -O diffusion_models/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf \
    "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q8_0.gguf" && \
wget -O diffusion_models/gimmvfi_r_arb_lpips_fp32.safetensors \
    "https://huggingface.co/Kijai/GIMM-VFI_safetensors/resolve/f06ecc593e175188d71d8c31c86bce83696430e5/gimmvfi_r_arb_lpips_fp32.safetensors"

echo "  📥 Downloading VAE..."
wget -O vae/wan_2.1_vae.safetensors \
    "https://huggingface.co/calcuis/wan-gguf/resolve/2f41e77bfc957eab2020821463d0cd7b15804bb9/wan_2.1_vae.safetensors"

echo "  📥 Downloading CLIP vision..."
wget -O clip_vision/clip_vision_h.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors?download=true"

echo "  📥 Downloading LoRAs..."
wget -O loras/low_noise_model.safetensors \
    "https://huggingface.co/lightx2v/Wan2.2-Lightning/resolve/main/Wan2.2-I2V-A14B-4steps-lora-rank64-Seko-V1/low_noise_model.safetensors" && \
wget -O loras/high_noise_model.safetensors \
    "https://huggingface.co/lightx2v/Wan2.2-Lightning/resolve/main/Wan2.2-I2V-A14B-4steps-lora-rank64-Seko-V1/high_noise_model.safetensors" && \
wget -O loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors" && \
wget -O loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors \
    "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors" && \
wget -O loras/NSFW-22-H-e8.safetensors \
    "https://huggingface.co/rahul7star/wan2.2Lora/resolve/1d1e553d07c1bb0e91765752413c4857e31df299/wan2.2/NSFW-22-H-e8.safetensors" && \
wget -O loras/NSFW-22-L-e8.safetensors \
    "https://huggingface.co/rahul7star/wan2.2Lora/resolve/main/NSFW-22-L-e8.safetensors"

echo "  📥 Downloading CLIP text encoder..."
wget -O clip/umt5_xxl_fp16.safetensors \
    "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors"

echo "✅ Setup complete! ComfyUI is ready to use."
echo "🚀 To start ComfyUI, run: comfy launch -- --listen 0.0.0.0 --port 8000"
echo "🌐 Access it at: http://localhost:8000"
