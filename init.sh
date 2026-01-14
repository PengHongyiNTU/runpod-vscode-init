#!/bin/bash 
# A simple VSCode Tunnel setup script for Runpod instances
# workspace dir persists
# Create bin directory
INSTALL_DIR="/workspace/bin"
DOWNLOAD_DIR="/workspace/downloads"
mkdir -p $INSTALL_DIR
mkdir -p $DOWNLOAD_DIR


# Check if VS Code CLI already exists
if [ ! -f $INSTALL_DIR/code ]; then
    echo "VS Code CLI not found. Downloading..."
    # Download the VS Code CLI
    wget -O $DOWNLOAD_DIR/vscode-cli.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
    # Extract the downloaded file
    tar -xzf $DOWNLOAD_DIR/vscode-cli.tar.gz -C $INSTALL_DIR
    chmod +x $INSTALL_DIR/code
    echo "VS Code CLI downloaded and installed."
else
    echo "VS Code CLI already exists."
fi


# Add VS Code CLI to PATH if not already present
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding VS Code CLI to PATH."
    export PATH="$INSTALL_DIR:$PATH"
    # Add to .bashrc for persistence
    echo 'export PATH="'"$INSTALL_DIR"':$PATH"' >> ~/.bashrc
else
    echo "VS Code CLI is already in PATH."
fi

echo "Starting VS Code Tunnel..."
# Start VS Code Tunnel
code tunnel