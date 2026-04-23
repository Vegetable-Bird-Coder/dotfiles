#!/bin/bash
# Dotfiles installer - creates symlinks from ~/.config to this repo

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
echo "✓ Ghostty config linked"

# Yazi
ln -sfn "$DOTFILES_DIR/yazi" ~/.config/yazi
echo "✓ Yazi config linked"

# Neovim
ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
echo "✓ Neovim config linked"

# Starship
mkdir -p ~/.config
ln -sf "$DOTFILES_DIR/starship/starship.toml" ~/.config/starship.toml
echo "✓ Starship config linked"

echo "Done! Restart your terminal to apply."
