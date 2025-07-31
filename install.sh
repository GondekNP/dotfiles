#!/bin/bash

# Dotfiles Installation Script
# Installs Claude Code, GitHub Copilot (VS Code), and Tmux with configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "$(pwd)/.git" ]; then
    DOTFILES_DIR="$(pwd)"
fi

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

# Check if running on supported OS
check_os() {
    log_info "Checking operating system compatibility..."
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Check if it's Ubuntu/Debian
        if command -v apt-get &> /dev/null; then
            log_success "Detected Ubuntu/Debian Linux"
            OS="ubuntu"
        else
            log_warning "Linux detected but not Ubuntu/Debian. Some features may not work."
            OS="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        log_success "Detected macOS"
        OS="macos"
    else
        log_error "Unsupported operating system: $OSTYPE"
        log_info "Supported: Ubuntu 20.04+, Debian 10+, macOS 10.15+"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is required but not installed."
        log_info "Please install Node.js 18+ from https://nodejs.org/"
        exit 1
    fi
    
    # Check Node.js version
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        log_error "Node.js version 18+ is required. Current version: $(node -v)"
        exit 1
    fi
    
    log_success "Node.js $(node -v) found"
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        log_error "Git is required but not installed."
        exit 1
    fi
    
    log_success "Git $(git --version | cut -d' ' -f3) found"
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        log_error "curl is required but not installed."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Make scripts executable
make_scripts_executable() {
    log_info "Making installation scripts executable..."
    chmod +x "$DOTFILES_DIR"/scripts/*.sh
    log_success "Scripts are now executable"
}

# Main installation function
main() {
    echo "======================================"
    echo "    Dotfiles Installation Script"
    echo "======================================"
    echo
    echo "This will install:"
    echo "• Claude Code (AI coding assistant)"
    echo "• VS Code extensions & configuration (for devcontainer)"
    echo "• GitHub Copilot extensions"
    echo "• Git repository autocomplete (branch completion)"
    echo "• Tmux (terminal multiplexer)"
    echo
    
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Installation cancelled by user"
        exit 0
    fi
    
    check_os
    check_prerequisites
    make_scripts_executable
    
    log_info "Starting installation process..."
    
    # Install Claude Code
    log_info "Installing Claude Code..."
    if "$DOTFILES_DIR/scripts/install-claude.sh"; then
        log_success "Claude Code installation completed"
    else
        log_error "Claude Code installation failed"
        exit 1
    fi
    
    # Install VS Code extensions and configuration
    log_info "Setting up VS Code extensions and configuration..."
    if "$DOTFILES_DIR/scripts/install-vscode.sh"; then
        log_success "VS Code setup completed"
    else
        log_error "VS Code setup failed"
        exit 1
    fi
    
    # Setup Git completion for repository autocomplete
    log_info "Setting up Git completion..."
    if "$DOTFILES_DIR/scripts/install-git-completion.sh"; then
        log_success "Git completion setup completed"
    else
        log_warning "Git completion setup had issues (non-critical)"
    fi
    
    # Install Tmux
    log_info "Installing Tmux..."
    if "$DOTFILES_DIR/scripts/install-tmux.sh"; then
        log_success "Tmux installation completed"
    else
        log_error "Tmux installation failed"
        exit 1
    fi
    
    echo
    echo "======================================"
    log_success "Installation completed successfully!"
    echo "======================================"
    echo
    echo "Next steps:"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Open VS Code and sign in to GitHub Copilot"
    echo "3. Run 'claude' in a project directory to start Claude Code"
    echo "4. Use 'tmux' to start a new terminal session"
    echo "5. Test Git completion: type 'git switch <TAB><TAB>' to see branches"
    echo
    echo "For troubleshooting, see: $DOTFILES_DIR/docs/"
}

# Run main function
main "$@"
