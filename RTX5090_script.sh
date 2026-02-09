#!/bin/bash

# -- Installation & Start Script ---
# Base image: runpod/pytorch:2.4.0-py3.11-cuda12.4.1-devel-ubuntu22.04
# This script installs and launches AUTOMATIC1111 Stable Diffusion WebUI
# on RunPod with no additional extensions or modifications.

set -e

WEBUI_DIR="/workspace/stable-diffusion-webui"

# ---- Install system dependencies ----
echo "Installing system dependencies..."
apt-get update && apt-get install -y --no-install-recommends \
    wget git libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# ---- Clone A1111 (skip if already present for pod restarts) ----
if [ ! -d "$WEBUI_DIR" ]; then
    echo "Cloning AUTOMATIC1111 Stable Diffusion WebUI..."
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "$WEBUI_DIR"
else
    echo "WebUI already exists, pulling latest changes..."
    cd "$WEBUI_DIR" && git pull
fi

# ---- Configure webui-user.sh ----
echo "Configuring webui-user.sh..."
cat > "$WEBUI_DIR/webui-user.sh" << 'EOF'
#!/bin/bash
export COMMANDLINE_ARGS="--listen --port 3000 --xformers --enable-insecure-extension-access --no-half-vae --api"
EOF

# ---- Clean up ----
echo "Cleaning up..."
rm -f /workspace/install_script.sh

# ---- Start services ----
echo "Starting RunPod handler and A1111 WebUI..."
/start.sh &
cd "$WEBUI_DIR" && bash webui.sh
