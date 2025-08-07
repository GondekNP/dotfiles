#!/bin/bash

# Setup Claude instructions by mirroring copilot instructions if they exist
# This script should be run in the target repository (not the dotfiles repo)

set -e

echo "Setting up Claude instructions..."

# Check if .github/copilot-instructions.md exists in the current directory
if [[ -f ".github/copilot-instructions.md" ]]; then
    echo "Found .github/copilot-instructions.md, creating CLAUDE.md mirror..."
    
    # Copy the content to CLAUDE.md
    cp ".github/copilot-instructions.md" "CLAUDE.md"
    
    # Add CLAUDE.md to the local git exclude file so it won't be tracked
    if [[ -d ".git" ]]; then
        echo "CLAUDE.md" >> .git/info/exclude
        echo "✅ Added CLAUDE.md to .git/info/exclude"
    fi
    
    echo "✅ Created CLAUDE.md with mirrored copilot instructions"
else
    echo "No .github/copilot-instructions.md found, skipping Claude setup"
fi

echo "Claude setup complete"