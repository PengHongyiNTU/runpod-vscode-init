#!/usr/bin/env bash
set -euo pipefail

WORKSPACE_DIR="/workspace"
INSTALL_DIR="$WORKSPACE_DIR/bin"

# --- sanity checks ---
if [[ ! -d "$WORKSPACE_DIR" ]]; then
  echo "❌ $WORKSPACE_DIR does not exist. Is your workspace mounted?"
  exit 1
fi
if [[ ! -w "$WORKSPACE_DIR" ]]; then
  echo "❌ $WORKSPACE_DIR is not writable."
  exit 1
fi

# --- persistent caches (recommended set) ---
export HF_HOME="$WORKSPACE_DIR/hf_cache"
export HUGGINGFACE_HUB_CACHE="$WORKSPACE_DIR/hf_hub_cache"
export HF_DATASETS_CACHE="$WORKSPACE_DIR/hf_datasets_cache"

export PIP_CACHE_DIR="$WORKSPACE_DIR/pip_cache"
export UV_CACHE_DIR="$WORKSPACE_DIR/uv_cache"
export RAY_TMPDIR="$WORKSPACE_DIR/ray_temp"

export TORCH_HOME="$WORKSPACE_DIR/torch_cache"
export WANDB_DIR="$WORKSPACE_DIR/wandb"
export XDG_CACHE_HOME="$WORKSPACE_DIR/xdg_cache"
export TRITON_CACHE_DIR="$WORKSPACE_DIR/triton_cache"

mkdir -p \
  "$INSTALL_DIR" \
  "$HF_HOME" "$HUGGINGFACE_HUB_CACHE" "$HF_DATASETS_CACHE" \
  "$PIP_CACHE_DIR" "$UV_CACHE_DIR" "$RAY_TMPDIR" \
  "$TORCH_HOME" "$WANDB_DIR" "$XDG_CACHE_HOME" "$TRITON_CACHE_DIR"


# Make it effective for current shell (not only future shells)
export PATH="$INSTALL_DIR:$PATH"

# --- Install VS Code CLI ---
if [[ ! -x "$INSTALL_DIR/code" ]]; then
  echo "⬇️ Downloading VS Code CLI..."
  tmpdir="$(mktemp -d)"
  # NOTE: you might need to change os=cli-linux-x64 depending on your base image.
  curl -L 'https://code.visualstudio.com/sha/download?build=stable&os=cli-linux-x64' \
    | tar -xz -C "$tmpdir"

  # Find the binary robustly
  if [[ -f "$tmpdir/code" ]]; then
    mv "$tmpdir/code" "$INSTALL_DIR/code"
  else
    found="$(find "$tmpdir" -maxdepth 3 -type f -name code | head -n 1 || true)"
    if [[ -z "${found}" ]]; then
      echo "❌ VS Code CLI extraction succeeded but 'code' not found."
      echo "   Please inspect: $tmpdir"
      exit 1
    fi
    mv "$found" "$INSTALL_DIR/code"
  fi

  chmod +x "$INSTALL_DIR/code"
  rm -rf "$tmpdir"
  echo "✅ VS Code CLI installed to $INSTALL_DIR/code"
else
  echo "✅ VS Code CLI already exists."
fi


# --- Update ~/.bashrc with a managed block (idempotent) ---
BASHRC="$HOME/.bashrc"
MARK_BEGIN="# >>> workspace-persist (managed) >>>"
MARK_END="# <<< workspace-persist (managed) <<<"

# Remove old block if exists
if [[ -f "$BASHRC" ]]; then
  awk -v b="$MARK_BEGIN" -v e="$MARK_END" '
    $0==b {inblock=1; next}
    $0==e {inblock=0; next}
    !inblock {print}
  ' "$BASHRC" > "${BASHRC}.tmp"
  mv "${BASHRC}.tmp" "$BASHRC"
fi

cat >> "$BASHRC" <<EOF
$MARK_BEGIN
export PATH="$INSTALL_DIR:\$PATH"
export HF_HOME="$HF_HOME"
export HUGGINGFACE_HUB_CACHE="$HUGGINGFACE_HUB_CACHE"
export HF_DATASETS_CACHE="$HF_DATASETS_CACHE"
export PIP_CACHE_DIR="$PIP_CACHE_DIR"
export UV_CACHE_DIR="$UV_CACHE_DIR"
export RAY_TMPDIR="$RAY_TMPDIR"
export TORCH_HOME="$TORCH_HOME"
export WANDB_DIR="$WANDB_DIR"
export XDG_CACHE_HOME="$XDG_CACHE_HOME"
export TRITON_CACHE_DIR="$TRITON_CACHE_DIR"
$MARK_END
EOF


echo "------------------------------------------------"
echo "🎉 Setup complete!"
echo "PATH now: $PATH"
echo "------------------------------------------------"
echo "ℹ️ Run: source ~/.bashrc  (or open a new shell) to apply in interactive sessions."
