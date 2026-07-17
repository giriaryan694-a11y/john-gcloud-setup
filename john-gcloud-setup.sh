#!/bin/bash

# ==============================================================================
# Setup Script written by Aryan Giri
# John the Ripper & Wordlists Manager for Google Cloud Shell
# Usage: ./john-gcloud-setup.sh [--install | --clean-up | -h | --help]
# Optimized for GCP Cloud Shell (2 vCPU, ~7GB RAM, 5GB persistent storage).
# Compiles John from source (bypassing outdated apt version).
# Downloads rockyou.txt via GitHub Release Asset (bypasses raw file limits).
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
    echo "                downloads rockyou.txt via wget (GitHub release asset),"
    echo "                and adds 'john' and 'johnny' aliases."
    echo ""
    echo "  --clean-up    Completely removes John the Ripper, all downloaded"
    echo "                wordlists, and cleans up your ~/.bashrc aliases"
    echo "                to keep your machine clean."
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

    # Download rockyou.txt reliably via wget (using GitHub release asset to avoid raw file limits)
    ROCKYOU_PATH="$WORDLISTS_DIR/rockyou.txt"
    if [ ! -f "$ROCKYOU_PATH" ]; then
        echo "[+] Downloading rockyou.txt via wget (GitHub release asset)..."
        wget -q -O "$ROCKYOU_PATH" "https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt"
        
        if [ -f "$ROCKYOU_PATH" ]; then
            echo "[+] Successfully downloaded rockyou.txt ($(du -h "$ROCKYOU_PATH" | awk '{print $1}'))."
        else
            echo "[!] Warning: Failed to download rockyou.txt. Please check your internet connection."
        fi
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
