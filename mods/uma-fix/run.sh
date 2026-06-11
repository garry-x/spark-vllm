#!/bin/bash
set -euo pipefail

PYTHON_ROOT="${PYTHON_ROOT:-/usr/local/lib/python3.12/dist-packages}"
MOD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="$MOD_DIR/uma_fix.patch"
UVA_FALLBACK_PATCH_FILE="$MOD_DIR/wsl-uva-fallback.patch"

apply_patch_once() {
  local name="$1"
  local patch_file="$2"

  if [ ! -f "$patch_file" ]; then
    echo "[uma-fix] $name patch not found: $patch_file" >&2
    exit 1
  elif git apply --reverse --check "$patch_file" 2>/dev/null; then
    echo "[uma-fix] $name patch is already applied; skipping."
  elif git apply --check "$patch_file"; then
    git apply "$patch_file"
    echo "[uma-fix] Applied $name patch."
  else
    echo "[uma-fix] $name patch could not be applied to installed vLLM." >&2
    exit 1
  fi
}

if ! command -v git >/dev/null 2>&1; then
  echo "[uma-fix] git is required to apply this mod." >&2
  echo "[uma-fix] Apply mods/use-official-vllm first if this container does not include git." >&2
  exit 1
fi

if [ ! -d "$PYTHON_ROOT/vllm" ]; then
  echo "[uma-fix] vLLM package not found at $PYTHON_ROOT/vllm" >&2
  exit 1
fi

cd "$PYTHON_ROOT"

apply_patch_once "UMA memory accounting fix" "$PATCH_FILE"
apply_patch_once "WSL UVA fallback" "$UVA_FALLBACK_PATCH_FILE"
