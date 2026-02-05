#!/bin/bash

# 1. GET CURRENT DIRECTORY
PLUGIN_PATH="$(pwd)"

echo "❄️  COLD NEO ENVIRONMENT SETUP ❄️"
echo "--------------------------------"

# 2. DETECT OS
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN"
esac

# 3. SET BIN_DIR
BIN_DIR="$HOME/.local/bin"

if [ ! -d "$BIN_DIR" ]; then
    echo "• Creating missing directory: $BIN_DIR"
    mkdir -p "$BIN_DIR"
fi

# 4. CHECK PATH (Fish, Zsh, Bash)
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo "• NOTICE: $BIN_DIR is not in your PATH."
    
    # Check for FISH Shell
    if [[ "$SHELL" == *"fish"* ]]; then
        FISH_CONFIG="$HOME/.config/fish/config.fish"
        echo "  -> Detected Fish Shell."
        
        if command -v fish_add_path &> /dev/null; then
            echo "  -> executing fish_add_path..."
            fish_add_path "$BIN_DIR"
        else
            echo "  -> Appending to $FISH_CONFIG..."
            mkdir -p "$(dirname "$FISH_CONFIG")"
            echo "" >> "$FISH_CONFIG"
            echo "# Added by Cold Neo Writer" >> "$FISH_CONFIG"
            echo "set -gx PATH $BIN_DIR \$PATH" >> "$FISH_CONFIG"
        fi
        echo "  -> Done. You may need to restart your terminal."

    else
        # Standard ZSH / BASH handling
        SHELL_CONFIG=""
        if [ -f "$HOME/.zshrc" ]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            SHELL_CONFIG="$HOME/.bash_profile"
        elif [ -f "$HOME/.bashrc" ]; then
            SHELL_CONFIG="$HOME/.bashrc"
        fi

        if [ -n "$SHELL_CONFIG" ]; then
            echo "  -> Adding it to $SHELL_CONFIG..."
            echo "" >> "$SHELL_CONFIG"
            echo "# Added by Cold Neo Writer" >> "$SHELL_CONFIG"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_CONFIG"
            echo "  -> Done. You may need to restart your terminal or run 'source $SHELL_CONFIG'"
        else
            echo "  [!] Could not detect shell config. Please manually add $BIN_DIR to your PATH."
        fi
    fi
fi

# 5. INSTALL NEOVIDE
echo "• Checking Neovide..."
if command -v neovide &> /dev/null; then
    echo "  -> Neovide is already installed."
else
    echo "  -> Installing Neovide..."
    if [ "$MACHINE" == "Mac" ]; then
        if command -v brew &> /dev/null; then 
            brew install neovide
        else 
            echo "  [ERROR] Homebrew not found. Please install Neovide manually."
        fi
    elif [ "$MACHINE" == "Linux" ]; then
        if command -v cargo &> /dev/null; then 
            cargo install neovide
        else 
            echo "  [WARN] Cargo not found. Install Neovide manually."
        fi
    fi
fi

# 6. CREATE LAUNCHER SCRIPT
LAUNCHER="$BIN_DIR/coldwriter"
echo "• Creating Launcher at $LAUNCHER..."

cat << 'EOF' > "$LAUNCHER"
#!/bin/bash
if [ -z "$1" ]; then
  echo "Usage: coldwriter <filename.tex>"
  exit 1
fi
# REMOVED --multigrid as it is now default in new versions
neovide --maximized "$1" -- -c "ColdStart 60"
EOF

chmod +x "$LAUNCHER"

echo "--------------------------------"
echo "✅ Setup Complete!"
echo "If 'coldwriter' command doesn't work immediately, restart your terminal."
