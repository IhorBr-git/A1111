#!/bin/bash

# -- Installation Script ---
# This script handles the full installation of AUTOMATIC1111 Stable Diffusion WebUI
# on RunPod (RTX 5090) without any extensions.

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

cd /workspace/stable-diffusion-webui

# ---- Create virtual environment ----
echo "Creating Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# ---- Install PyTorch with CUDA support ----
echo "Installing PyTorch with CUDA support..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu124

# ---- Install A1111 dependencies ----
echo "Installing A1111 dependencies..."
pip install -r requirements_versions.txt
pip install xformers

# ---- Create run script ----
echo "Creating run script..."
cat > /workspace/run_a1111.sh << 'EOF'
#!/bin/bash
cd /workspace/stable-diffusion-webui
source venv/bin/activate
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
