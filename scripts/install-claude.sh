#!/bin/bash

# Claude Code Installation Script
# Installs Anthropic's Claude Code AI coding assistant

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Claude Code is already installed
check_existing_installation() {
    if command -v claude &> /dev/null; then
        CURRENT_VERSION=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        log_warning "Claude Code is already installed (${CURRENT_VERSION})"
        log_info "Updating Claude Code automatically..."
        claude update || log_warning "Update failed, continuing with installation"
    fi
    return 0
}

# Install Claude Code via npm
install_claude_npm() {
    log_info "Installing Claude Code via npm..."
    
    # Check npm permissions
    if npm list -g --depth=0 &> /dev/null; then
        log_info "npm global permissions look good"
    else
        log_warning "npm global permissions may be problematic"
        log_info "If installation fails, see: https://docs.anthropic.com/en/docs/claude-code/troubleshooting#linux-permission-issues"
    fi
    
    # Install Claude Code globally
    if npm install -g @anthropic-ai/claude-code --no-optional; then
        log_success "Claude Code installed successfully via npm"
        return 0
    else
        log_error "npm installation failed"
        return 1
    fi
}

# Install Claude Code via curl (alternative method)
install_claude_curl() {
    log_info "Attempting installation via curl (alpha method)..."
    
    if curl -fsSL claude.ai/install.sh | bash; then
        log_success "Claude Code installed successfully via curl"
        return 0
    else
        log_error "curl installation failed"
        return 1
    fi
}

# Run post-installation checks
post_install_check() {
    log_info "Running post-installation checks..."
    
    # Check if claude command is available
    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null | head -n1 || echo "unknown")
        log_success "Claude Code is available: ${CLAUDE_VERSION}"
        
        # Skip claude doctor to avoid interactive prompts
        log_info "Skipping Claude Code diagnostics (can be run manually with 'claude doctor')"
        
        return 0
    else
        log_error "Claude Code command not found after installation"
        return 1
    fi
}

# Add Claude to PATH if needed
ensure_claude_in_path() {
    # Check if claude is in PATH
    if ! command -v claude &> /dev/null; then
        log_info "Adding Claude Code to PATH..."
        
        # Common npm global bin directory
        NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "$HOME/.npm-global")
        CLAUDE_BIN="$NPM_PREFIX/bin"
        
        if [ -f "$CLAUDE_BIN/claude" ]; then
            # Add to bashrc
            if ! grep -q "$CLAUDE_BIN" ~/.bashrc 2>/dev/null; then
                echo "export PATH=\"$CLAUDE_BIN:\$PATH\"" >> ~/.bashrc
                log_success "Added Claude Code to ~/.bashrc"
            fi
            
            # Add to zshrc if it exists
            if [ -f ~/.zshrc ] && ! grep -q "$CLAUDE_BIN" ~/.zshrc; then
                echo "export PATH=\"$CLAUDE_BIN:\$PATH\"" >> ~/.zshrc
                log_success "Added Claude Code to ~/.zshrc"
            fi
            
            # Export for current session
            export PATH="$CLAUDE_BIN:$PATH"
        fi
    fi
}

# Main installation function
main() {
    echo "======================================"
    echo "    Claude Code Installation"
    echo "======================================"
    echo
    
    log_info "Installing Anthropic Claude Code..."
    log_info "This may take a few minutes..."
    
    # Skip if already installed and user doesn't want to update
    if ! check_existing_installation; then
        return 0
    fi
    
    # Try npm installation first
    if install_claude_npm; then
        ensure_claude_in_path
        post_install_check
        return 0
    fi
    
    log_warning "npm installation failed, trying alternative method..."
    
    # Try curl installation as fallback
    if install_claude_curl; then
        ensure_claude_in_path
        post_install_check
        return 0
    fi
    
    # Both methods failed
    log_error "All installation methods failed"
    echo
    echo "Manual installation options:"
    echo "1. Fix npm permissions: https://docs.anthropic.com/en/docs/claude-code/troubleshooting#linux-permission-issues"
    echo "2. Try: npm config set prefix ~/.npm-global"
    echo "3. Ensure Node.js 18+ is installed"
    echo
    return 1
}

# Run main function
main "$@"
