#!/bin/bash

# ==============================================================================
# Setup Script written by Aryan Giri
# John the Ripper & Wordlists Manager for GCP Cloud Shell
# Usage: ./john.sh [--install | --clean-up | -h | --help]
# Optimized for GCP Cloud Shell (2 vCPU, ~7GB RAM, 5GB persistent storage).
# Compiles John from source (bypassing outdated apt version).
# ==============================================================================

# 1. Define Directory Structure
BASE_DIR="$HOME/security_tools"
JOHN_DIR="$BASE_DIR/john"
WORDLISTS_DIR="$BASE_DIR/wordlists"
JOHN_BIN_DIR="$JOHN_DIR/run"
BASHRC_FILE="$HOME/.bashrc"

# ==============================================================================
# FUNCTIONS
# ==============================================================================

show_help() {
    echo "============================================================"
    echo " John the Ripper & Wordlists Manager for GCP Cloud Shell"
    echo "============================================================"
    echo ""
    echo "USAGE:"
    echo "  ./john-gcloud-setup.sh [FLAG]"
    echo ""
    echo "FLAGS:"
    echo "  --install     Compiles the latest John the Ripper (Jumbo) from source,"
    echo "                installs the Python 'wordlists' package, and reliably"
    echo "                downloads/extracts rockyou.txt. Adds 'john' and 'johnny' aliases."
    echo ""
    echo "  --clean-up    Completely removes John the Ripper, all downloaded"
    echo "                wordlists, the Python package, and cleans up your"
    echo "                ~/.bashrc aliases to keep your machine clean."
    echo ""
    echo "  -h, --help    Displays this help message."
    echo ""
    echo "============================================================"
}

do_install() {
    echo "============================================================"
    echo " STARTING INSTALLATION (Optimized for 2 vCPU / 7GB RAM)"
    echo "============================================================"

    mkdir -p "$BASE_DIR"
    mkdir -p "$WORDLISTS_DIR"

    # Clone and Compile John
    if [ ! -d "$JOHN_DIR" ]; then
        echo "[+] Cloning latest John the Ripper (Jumbo) from source..."
        git clone https://github.com/openwall/john.git "$JOHN_DIR"
    else
        echo "[*] John directory already exists. Skipping clone."
    fi

    echo "[+] Configuring and compiling John the Ripper..."
    echo "[+] Using -j2 to utilize both vCPUs for faster compilation."
    cd "$JOHN_DIR/src" || { echo "[!] Failed to enter source directory."; exit 1; }
    
    ./configure
    make -s clean
    make -s -j2

    # Install Python package
    echo "[+] Installing Python 'wordlists' package via pip..."
    python3 -m pip install --user -q wordlists || echo "[!] Warning: Python wordlists package installation failed, continuing..."

    # Download/Extract rockyou.txt reliably via apt (avoids GitHub 100MB raw file limits)
    ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"
    if [ ! -f "$ROCKYOU_PATH" ]; then
        echo "[+] Installing system 'wordlists' package to get rockyou.txt reliably..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq wordlists
        
        echo "[+] Extracting rockyou.txt to $WORDLISTS_DIR..."
        gunzip -c /usr/share/wordlists/rockyou.txt.gz > "$ROCKYOU_PATH"
        echo "[+] Successfully extracted rockyou.txt ($(du -h "$ROCKYOU_PATH" | awk '{print $1}'))."
    else
        echo "[*] rockyou.txt already exists. Skipping download."
    fi

    # Persist Aliases (Using aliases instead of PATH to satisfy John's path-awareness)
    if ! grep -q "alias john=" "$BASHRC_FILE"; then
        echo "[+] Adding John aliases to ~/.bashrc..."
        echo "alias john='$JOHN_BIN_DIR/john'" >> "$BASHRC_FILE"
        echo "alias johnny='$JOHN_BIN_DIR/john'" >> "$BASHRC_FILE"
    else
        echo "[*] John aliases are already in ~/.bashrc."
    fi

    echo ""
    echo "============================================================"
    echo " ✅ INSTALLATION COMPLETE"
    echo "============================================================"
    echo "📂 Base Directory   : $BASE_DIR"
    echo "🔑 John Binary      : $JOHN_BIN_DIR/john"
    echo "📚 Wordlists Dir    : $WORDLISTS_DIR"
    echo "📄 Rockyou Path     : $ROCKYOU_PATH"
    echo "🐍 Python Package   : 'wordlists' (installed via pip --user)"
    echo "============================================================"
    echo "⚠️  IMPORTANT NEXT STEP:"
    echo "You MUST reload your shell for the 'john' command to work."
    echo "Run this command right now:"
    echo "   source ~/.bashrc"
    echo "   (or simply type: bash)"
    echo "============================================================"
}

do_cleanup() {
    echo "============================================================"
    echo " INITIATING CLEAN-UP"
    echo "============================================================"
    
    read -p "This will delete John, all wordlists, and remove aliases. Continue? (y/N): " confirm
    if [[ "$confirm" != [yY] ]]; then
        echo "[*] Clean-up aborted."
        exit 0
    fi

    if [ -d "$BASE_DIR" ]; then
        echo "[+] Removing $BASE_DIR..."
        rm -rf "$BASE_DIR"
    else
        echo "[*] Base directory not found. Skipping."
    fi

    echo "[+] Uninstalling Python 'wordlists' package..."
    python3 -m pip uninstall -y --user wordlists > /dev/null 2>&1 || echo "[*] Python package not found or already removed."

    if grep -q "alias john=" "$BASHRC_FILE"; then
        echo "[+] Removing John aliases from ~/.bashrc..."
        sed -i "\|alias john=|d" "$BASHRC_FILE"
        sed -i "\|alias johnny=|d" "$BASHRC_FILE"
    else
        echo "[*] John aliases not found in ~/.bashrc."
    fi

    echo ""
    echo "============================================================"
    echo " ✅ CLEAN-UP COMPLETE"
    echo "============================================================"
    echo "All John the Ripper files, wordlists, and aliases"
    echo "have been successfully removed from your Cloud Shell."
    echo "[!] Run 'source ~/.bashrc' to apply changes."
    echo "============================================================"
}

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

case "$1" in
    --install)
        do_install
        ;;
    --clean-up)
        do_cleanup
        ;;
    -h|--help|"")
        show_help
        ;;
    *)
        echo "Error: Unknown option '$1'"
        echo ""
        show_help
        exit 1
        ;;
esac
