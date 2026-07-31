#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PACKAGES=(
  alacritty
  herdr
  nvim
  tmux
  wezterm
)

if ! command -v stow >/dev/null 2>&1; then
  echo "stow not found — installing via Homebrew..."
  brew install stow
fi

cd "$DOTFILES"
stow --verbose --target "$HOME" "${PACKAGES[@]}"

echo "Done. Dotfiles stowed into $HOME"
