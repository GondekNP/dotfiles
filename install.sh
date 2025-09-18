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

# Install Node.js if needed
install_nodejs() {
    log_info "Installing Node.js 18+ in user space..."

    # Try to install Node.js via nvm (Node Version Manager) for user-space installation
    if ! command -v nvm &> /dev/null; then
        log_info "Installing nvm for user-space Node.js management..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    fi

    # Install Node.js 18 using nvm
    if command -v nvm &> /dev/null; then
        nvm install 18
        nvm use 18
        nvm alias default 18
        log_success "Node.js installed via nvm"
    else
        # Fallback: Download Node.js binary directly
        log_info "Installing Node.js binary to user directory..."
        NODE_VERSION="v18.19.0"
        NODE_ARCH="$(uname -m)"
        if [[ "$NODE_ARCH" == "x86_64" ]]; then
            NODE_ARCH="x64"
        elif [[ "$NODE_ARCH" == "aarch64" ]]; then
            NODE_ARCH="arm64"
        fi

        NODE_URL="https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-${NODE_ARCH}.tar.xz"

        mkdir -p "$HOME/.local"
        curl -L "$NODE_URL" | tar -xJ -C "$HOME/.local" --strip-components=1

        # Add to PATH if not already there
        if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
            export PATH="$HOME/.local/bin:$PATH"
        fi

        log_success "Node.js installed to ~/.local"
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for Node.js
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found. Installing Node.js 18+..."
        install_nodejs
    else
        # Check Node.js version
        NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -lt 18 ]; then
            log_warning "Node.js version 18+ is required. Current version: $(node -v). Upgrading..."
            install_nodejs
        else
            log_success "Node.js $(node -v) found"
        fi
    fi
    
    # Check for Git
    if ! command -v git &> /dev/null; then
        log_error "Git is required but not found."
        log_info "In container environments, Git should be pre-installed."
        log_info "Please contact your system administrator or install Git manually."
        # In most devcontainers, git is pre-installed, so this is likely an edge case
        exit 1
    fi
    
    log_success "Git $(git --version | cut -d' ' -f3) found"
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        # Try wget as fallback
        if command -v wget &> /dev/null; then
            log_warning "curl not found, but wget is available. Using wget as fallback."
            # Create curl wrapper function
            curl() {
                wget -qO- "$@"
            }
            export -f curl
        else
            log_error "Neither curl nor wget found."
            log_info "These tools are usually pre-installed in containers."
            log_info "Please contact your system administrator."
            exit 1
        fi
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
    
    log_info "Starting automatic installation..."
    
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
    
    # Setup Claude instructions (mirror copilot instructions if they exist)
    log_info "Setting up Claude instructions..."
    if "$DOTFILES_DIR/scripts/setup-claude.sh"; then
        log_success "Claude instructions setup completed"
    else
        log_warning "Claude instructions setup had issues (non-critical)"
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
