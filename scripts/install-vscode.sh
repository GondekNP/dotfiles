#!/bin/bash

# VS Code Extensions and GitHub Copilot Setup Script
# Configures VS Code extensions and settings for devcontainer usage
# Does not install VS Code itself (assumes running in devcontainer)

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

# Dotfiles directory
DOTFILES_DIR="$HOME/.dotfiles"
if [ -d "$(dirname "$(dirname "$0")")/.git" ]; then
    DOTFILES_DIR="$(dirname "$(dirname "$0")")"
fi

# Check if VS Code is available (should be in devcontainer)
check_vscode_availability() {
    if command -v code &> /dev/null; then
        log_success "VS Code CLI is available"
        return 0
    else
        log_warning "VS Code CLI not found - this is expected in some devcontainer setups"
        log_info "Extensions will be configured for manual installation"
        return 1
    fi
}

# Essential VS Code extensions including Git repository support
declare -a EXTENSIONS=(
    "GitHub.copilot"                    # GitHub Copilot - AI pair programmer
    "GitHub.copilot-chat"               # GitHub Copilot Chat - AI conversations
    "GitHub.vscode-pull-request-github" # GitHub Pull Requests - repo integration
    "eamodio.gitlens"                   # GitLens - Git supercharged
    "ms-vscode.vscode-typescript-next"  # TypeScript support
    "ms-python.python"                  # Python support
    "ms-vscode.cpptools"                # C/C++ support
    "rust-lang.rust-analyzer"           # Rust support
    "bradlc.vscode-tailwindcss"         # Tailwind CSS
    "esbenp.prettier-vscode"            # Code formatter
    "ms-vscode.vscode-json"             # JSON support
    "redhat.vscode-yaml"                # YAML support
    "ms-vscode-remote.remote-ssh"       # Remote SSH
    "ms-vscode-remote.remote-containers" # Dev Containers
    "ms-vscode.remote-explorer"         # Remote Explorer
    "ms-vscode.hexeditor"               # Hex editor
    "ms-vscode.live-server"             # Live server
    "ms-toolsai.jupyter"                # Jupyter notebooks
)

# Install VS Code extensions (if code CLI is available)
install_extensions() {
    if ! check_vscode_availability; then
        log_warning "VS Code CLI not available - creating extension list for manual installation"
        create_extension_list
        return 0
    fi
    
    log_info "Installing VS Code extensions..."
    
    for extension in "${EXTENSIONS[@]}"; do
        log_info "Installing extension: $extension"
        if code --install-extension "$extension" --force; then
            log_success "✓ $extension"
        else
            log_warning "✗ Failed to install $extension"
        fi
    done
    
    log_success "VS Code extensions installation completed"
}

# Create extension list for manual installation
create_extension_list() {
    local extension_file="$DOTFILES_DIR/vscode-extensions.txt"
    
    log_info "Creating extension list at: $extension_file"
    
    cat > "$extension_file" << EOF
# VS Code Extensions for Devcontainer
# Install these manually in VS Code or use: cat vscode-extensions.txt | xargs -L1 code --install-extension

EOF
    
    for extension in "${EXTENSIONS[@]}"; do
        echo "$extension" >> "$extension_file"
    done
    
    log_success "Extension list created. To install manually:"
    echo "  cat $extension_file | grep -v '^#' | xargs -L1 code --install-extension"
}

# Create VS Code settings
setup_vscode_settings() {
    log_info "Setting up VS Code configuration..."
    
    # Create VS Code config directory
    VSCODE_CONFIG_DIR="$HOME/.config/Code/User"
    mkdir -p "$VSCODE_CONFIG_DIR"
    
    # Copy settings if they exist in dotfiles
    if [ -f "$DOTFILES_DIR/config/vscode/settings.json" ]; then
        cp "$DOTFILES_DIR/config/vscode/settings.json" "$VSCODE_CONFIG_DIR/"
        log_success "VS Code settings applied"
    else
        log_info "No custom VS Code settings found, using defaults"
    fi
    
    # Copy keybindings if they exist
    if [ -f "$DOTFILES_DIR/config/vscode/keybindings.json" ]; then
        cp "$DOTFILES_DIR/config/vscode/keybindings.json" "$VSCODE_CONFIG_DIR/"
        log_success "VS Code keybindings applied"
    fi
}

# Check GitHub Copilot status
check_copilot_auth() {
    log_info "Checking GitHub Copilot authentication..."
    log_warning "After installation, you'll need to:"
    echo "1. Open VS Code"
    echo "2. Sign in to GitHub (Ctrl+Shift+P -> 'GitHub: Sign In')"
    echo "3. Activate GitHub Copilot in your account settings"
    echo "4. Restart VS Code"
    echo
}

# Main installation function
main() {
    echo "======================================"
    echo "  VS Code Extensions & Config Setup"
    echo "======================================"
    echo
    echo "Configuring for devcontainer usage..."
    echo
    
    # Check VS Code availability
    VSCODE_AVAILABLE=false
    if check_vscode_availability; then
        VSCODE_AVAILABLE=true
    fi
    
    # Install extensions (or create list for manual installation)
    install_extensions
    
    # Setup configuration
    setup_vscode_settings
    
    # Authentication reminder
    check_copilot_auth
    
    log_success "VS Code configuration completed!"
    
    if [ "$VSCODE_AVAILABLE" = false ]; then
        echo
        log_info "Since VS Code CLI wasn't available, check vscode-extensions.txt for manual installation"
    fi
    
    return 0
}

# Run main function
main "$@"
