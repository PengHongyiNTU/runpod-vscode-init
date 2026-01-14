#!/bin/bash

# 1. Define Paths
INSTALL_DIR="/workspace/bin"
mkdir -p "$INSTALL_DIR"

# 2. Install VS Code CLI (Persistent)
if [ ! -f "$INSTALL_DIR/code" ]; then
    echo "⬇️ Downloading VS Code CLI..."
    curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' | tar -xz --no-same-owner -C "$INSTALL_DIR"
    chmod +x "$INSTALL_DIR/code"
else
    echo "✅ VS Code CLI already exists."
fi

# 3. Install nvitop (GPU Monitor)
if ! command -v nvitop &> /dev/null; then
    echo "⬇️ Installing nvitop..."
    pip install nvitop --break-system-packages
else
    echo "✅ nvitop already installed."
fi

# 4. Update .bashrc (Avoid Duplicates)
if ! grep -q "$INSTALL_DIR" ~/.bashrc; then
    echo "📝 Adding paths to .bashrc..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> ~/.bashrc
    echo "export HF_HOME=\"/workspace/hf_cache\"" >> ~/.bashrc
fi

echo "------------------------------------------------"
echo "🎉 Setup complete!"
echo "Refreshing your shell to apply changes..."
echo "------------------------------------------------"

# 5. The Magic Trick: Automatically refresh the shell
# This replaces the current shell process with a fresh one that has the new PATH
exec bash