#!/bin/bash

# -- Installation Script ---
# This script handles the full installation of AUTOMATIC1111 Stable Diffusion WebUI
# on RunPod (RTX 5090) without any extensions.
# launch.py handles venv creation, torch, and all dependencies automatically.

set -e

# Change to the /workspace directory to ensure all files are downloaded correctly.
cd /workspace

# ---- Clone A1111 ----
echo "Cloning AUTOMATIC1111 Stable Diffusion WebUI..."
if [ ! -d "/workspace/stable-diffusion-webui" ]; then
    git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git /workspace/stable-diffusion-webui
else
    echo "Repository already exists, pulling latest changes..."
    git -C /workspace/stable-diffusion-webui pull
fi

# ---- Create run script ----
echo "Creating run script..."
cat > /workspace/run_a1111.sh << 'EOF'
#!/bin/bash
cd /workspace/stable-diffusion-webui
python launch.py \
    --listen \
    --port 3000 \
    --xformers \
    --enable-insecure-extension-access \
    --no-half-vae \
    --api
EOF
chmod +x /workspace/run_a1111.sh

# ---- Clean up ----
echo "Cleaning up..."
rm -f /workspace/install_script.sh

# ---- Start services ----
echo "Starting A1111 and RunPod services..."
(/start.sh & /workspace/run_a1111.sh)
