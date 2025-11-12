#!/bin/bash

# OpenCode AI Installation Script
# Installs OpenCode AI coding assistant

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

# Check if OpenCode is already installed
check_existing_installation() {
    if command -v opencode &> /dev/null; then
        CURRENT_VERSION=$(opencode --version 2>/dev/null | head -n1 || echo "unknown")
        log_warning "OpenCode is already installed (${CURRENT_VERSION})"
        log_info "You can update manually if needed"
        return 0
    fi
    return 1
}

# Install OpenCode via universal script (recommended)
install_opencode_universal() {
    log_info "Installing OpenCode via universal install script..."

    if curl -fsSL https://opencode.ai/install | bash; then
        log_success "OpenCode installed successfully via universal script"
        return 0
    else
        log_error "Universal script installation failed"
        return 1
    fi
}

# Install OpenCode via npm
install_opencode_npm() {
    log_info "Installing OpenCode via npm..."

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        log_error "npm not found - please install Node.js and npm first"
        return 1
    fi

    # Check npm permissions
    if npm list -g --depth=0 &> /dev/null; then
        log_info "npm global permissions look good"
    else
        log_warning "npm global permissions may be problematic"
    fi

    # Install OpenCode globally
    if npm install -g opencode-ai; then
        log_success "OpenCode installed successfully via npm"
        return 0
    else
        log_error "npm installation failed"
        return 1
    fi
}

# Install OpenCode via Homebrew (macOS/Linux)
install_opencode_homebrew() {
    log_info "Installing OpenCode via Homebrew..."

    if ! command -v brew &> /dev/null; then
        log_error "Homebrew not found"
        return 1
    fi

    if brew install opencode; then
        log_success "OpenCode installed successfully via Homebrew"
        return 0
    else
        log_error "Homebrew installation failed"
        return 1
    fi
}

# Setup OpenCode configuration
setup_opencode_config() {
    log_info "Setting up OpenCode configuration..."

    # Determine the dotfiles directory
    if [ -n "$DOTFILES_DIR" ]; then
        CONFIG_SOURCE="$DOTFILES_DIR/config/opencode.json"
    else
        # Fallback to current directory if DOTFILES_DIR not set
        CONFIG_SOURCE="$(dirname "$(dirname "$(realpath "$0")")")/config/opencode.json"
    fi

    # Check if opencode.json exists in current directory
    if [ ! -f "./opencode.json" ]; then
        if [ -f "$CONFIG_SOURCE" ]; then
            log_info "Copying OpenCode configuration with NRP AI provider..."
            cp "$CONFIG_SOURCE" "./opencode.json"
            log_success "OpenCode configuration copied to current directory"
        else
            log_warning "OpenCode configuration template not found at $CONFIG_SOURCE"
        fi
    else
        log_info "OpenCode configuration already exists in current directory"
    fi
}

# Run post-installation checks
post_install_check() {
    log_info "Running post-installation checks..."

    # Check if opencode command is available
    if command -v opencode &> /dev/null; then
        OPENCODE_VERSION=$(opencode --version 2>/dev/null | head -n1 || echo "unknown")
        log_success "OpenCode is available: ${OPENCODE_VERSION}"

        # Setup configuration
        setup_opencode_config

        log_info "Next steps:"
        echo "  1. Set your NRP_API_KEY environment variable (get token from NRP LLM token page)"
        echo "  2. Run 'opencode auth login' to configure your credentials"
        echo "  3. Use 'opencode' to start coding with NRP AI models"
        echo "  4. See https://opencode.ai/docs for usage instructions"

        return 0
    else
        log_error "OpenCode command not found after installation"
        return 1
    fi
}

# Add OpenCode to PATH if needed
ensure_opencode_in_path() {
    # Check if opencode is in PATH
    if ! command -v opencode &> /dev/null; then
        log_info "Checking common installation paths..."

        # Common npm global bin directory
        NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "$HOME/.npm-global")
        OPENCODE_BIN="$NPM_PREFIX/bin"

        if [ -f "$OPENCODE_BIN/opencode" ]; then
            # Add to bashrc
            if ! grep -q "$OPENCODE_BIN" ~/.bashrc 2>/dev/null; then
                echo "export PATH=\"$OPENCODE_BIN:\$PATH\"" >> ~/.bashrc
                log_success "Added OpenCode to ~/.bashrc"
            fi

            # Add to zshrc if it exists
            if [ -f ~/.zshrc ] && ! grep -q "$OPENCODE_BIN" ~/.zshrc; then
                echo "export PATH=\"$OPENCODE_BIN:\$PATH\"" >> ~/.zshrc
                log_success "Added OpenCode to ~/.zshrc"
            fi

            # Export for current session
            export PATH="$OPENCODE_BIN:$PATH"
        fi
    fi
}

# Main installation function
main() {
    echo "======================================"
    echo "     OpenCode AI Installation"
    echo "======================================"
    echo

    log_info "Installing OpenCode AI..."
    log_info "This may take a few minutes..."

    # Check if already installed
    if check_existing_installation; then
        log_info "OpenCode is already installed"
        return 0
    fi

    # Detect platform and try best installation method
    if [[ "$OSTYPE" == "darwin"* ]] && command -v brew &> /dev/null; then
        # macOS with Homebrew
        if install_opencode_homebrew; then
            post_install_check
            return 0
        fi
        log_warning "Homebrew installation failed, trying universal script..."
    fi

    # Try universal script first (recommended)
    if install_opencode_universal; then
        ensure_opencode_in_path
        post_install_check
        return 0
    fi

    log_warning "Universal script installation failed, trying npm..."

    # Try npm installation as fallback
    if install_opencode_npm; then
        ensure_opencode_in_path
        post_install_check
        return 0
    fi

    # All methods failed
    log_error "All installation methods failed"
    echo
    echo "Manual installation options:"
    echo "1. Try: curl -fsSL https://opencode.ai/install | bash"
    echo "2. Try: npm install -g opencode-ai"
    echo "3. macOS: brew install opencode"
    echo "4. See https://opencode.ai/docs/#install for more options"
    echo
    return 1
}

# Run main function
main "$@"