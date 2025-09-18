#!/bin/bash

# Setup Claude instructions and subagents by mirroring copilot instructions if they exist
# This script should be run in the target repository (not the dotfiles repo)

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo "Setting up Claude instructions and subagents..."

# Determine the dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "$(pwd)/.git" ] && [ -f "$(pwd)/install.sh" ]; then
    # We're in the dotfiles repo itself, look for .claude directory here
    DOTFILES_DIR="$(pwd)"
elif [ -d "$HOME/.dotfiles/.claude" ]; then
    # Standard dotfiles location
    DOTFILES_DIR="$HOME/.dotfiles"
else
    # Try to find dotfiles directory
    for dir in "$HOME/dotfiles" "$HOME/.config/dotfiles" "$(dirname "$0")/.."; do
        if [ -d "$dir/.claude" ]; then
            DOTFILES_DIR="$dir"
            break
        fi
    done
fi

# Copy .claude directory with subagents if it exists
if [[ -d "$DOTFILES_DIR/.claude" ]]; then
    log_info "Found .claude directory in dotfiles, copying subagents to target repository..."
    
    # Create .claude directory if it doesn't exist
    mkdir -p ".claude"
    
    # Copy the entire .claude directory contents
    cp -r "$DOTFILES_DIR/.claude"/* ".claude/"
    
    # Add .claude directory to the local git exclude file so it won't be tracked
    if [[ -d ".git" ]]; then
        echo ".claude/" >> .git/info/exclude
        log_success "Added .claude/ to .git/info/exclude"
    fi
    
    log_success "Copied Claude subagents from $DOTFILES_DIR/.claude to ./.claude"
else
    log_info "No .claude directory found in dotfiles ($DOTFILES_DIR), skipping subagent setup"
fi

# Check if .github/copilot-instructions.md exists in the current directory
if [[ -f ".github/copilot-instructions.md" ]]; then
    log_info "Found .github/copilot-instructions.md, creating CLAUDE.md mirror..."
    
    # Copy the content to CLAUDE.md
    cp ".github/copilot-instructions.md" "CLAUDE.md"
    
    # Add CLAUDE.md to the local git exclude file so it won't be tracked
    if [[ -d ".git" ]]; then
        echo "CLAUDE.md" >> .git/info/exclude
        log_success "Added CLAUDE.md to .git/info/exclude"
    fi
    
    log_success "Created CLAUDE.md with mirrored copilot instructions"
else
    log_info "No .github/copilot-instructions.md found, skipping CLAUDE.md setup"
fi

echo "Claude setup complete"