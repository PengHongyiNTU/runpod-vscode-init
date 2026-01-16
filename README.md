
# Runpod VS Code CLI Init (Simple Version)

This repo provides a simple shell script to install the VS Code CLI on a Runpod GPU instance and persist common caches under `/workspace`.

## Usage

```bash
git clone https://github.com/PengHongyiNTU/runpod-vscode-init.git
cd runpod-vscode-init
chmod +x init.sh
bash init.sh
```

## Start a VS Code Tunnel

After installation, start the tunnel with:

```bash
source ~/.bashrc
code tunnel
```

