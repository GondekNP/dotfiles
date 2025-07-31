#!/bin/bash

# Git Completion Setup Script
# Ensures Git branch and command completion works properly

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

# Install bash-completion package
install_bash_completion() {
    log_info "Installing bash-completion package..."
    
    case "$OSTYPE" in
        linux-gnu*)
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y bash-completion git
                log_success "bash-completion and git installed via apt"
            elif command -v yum &> /dev/null; then
                sudo yum install -y bash-completion git
                log_success "bash-completion and git installed via yum"
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y bash-completion git
                log_success "bash-completion and git installed via dnf"
            else
                log_warning "Package manager not found, trying manual installation"
                return 1
            fi
            ;;
        darwin*)
            if command -v brew &> /dev/null; then
                brew install bash-completion git
                log_success "bash-completion and git installed via Homebrew"
            else
                log_error "Homebrew not found. Please install it first."
                return 1
            fi
            ;;
        *)
            log_error "Unsupported operating system: $OSTYPE"
            return 1
            ;;
    esac
    
    return 0
}

# Download git completion manually if needed
install_git_completion_manual() {
    log_info "Installing Git completion manually..."
    
    local completion_url="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
    local completion_file="$HOME/.git-completion.bash"
    
    if command -v curl &>/dev/null; then
        if curl -fsSL -o "$completion_file" "$completion_url"; then
            log_success "Git completion downloaded via curl"
        else
            log_error "Failed to download Git completion"
            return 1
        fi
    elif command -v wget &>/dev/null; then
        if wget -O "$completion_file" "$completion_url"; then
            log_success "Git completion downloaded via wget"
        else
            log_error "Failed to download Git completion"
            return 1
        fi
    else
        log_error "Neither curl nor wget available"
        return 1
    fi
    
    return 0
}

# Test git completion
test_git_completion() {
    log_info "Testing Git completion..."
    
    # Source the completion
    if [ -f /usr/share/bash-completion/completions/git ]; then
        # shellcheck source=/dev/null
        source /usr/share/bash-completion/completions/git
    elif [ -f /etc/bash_completion.d/git ]; then
        # shellcheck source=/dev/null
        source /etc/bash_completion.d/git
    elif [ -f "$HOME/.git-completion.bash" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.git-completion.bash"
    fi
    
    # Check if git completion function exists
    if type __git_complete &>/dev/null; then
        log_success "Git completion is working!"
        return 0
    else
        log_warning "Git completion function not found"
        return 1
    fi
}

# Setup completion in shell config
setup_shell_completion() {
    log_info "Setting up completion in shell configuration..."
    
    local completion_setup='
# Git completion setup
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Load Git completion if available
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
elif [ -f /etc/bash_completion.d/git ]; then
    source /etc/bash_completion.d/git
elif [ -f ~/.git-completion.bash ]; then
    source ~/.git-completion.bash
fi
'
    
    # Add to bashrc if not already present
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "Git completion setup" "$HOME/.bashrc"; then
            echo "$completion_setup" >> "$HOME/.bashrc"
            log_success "Git completion added to ~/.bashrc"
        else
            log_info "Git completion already configured in ~/.bashrc"
        fi
    fi
    
    # Add to zshrc if it exists and is different
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "Git completion setup" "$HOME/.zshrc"; then
            # Zsh has different completion system
            echo '
# Git completion for zsh
autoload -Uz compinit && compinit
autoload -U +X bashcompinit && bashcompinit
if [ -f /usr/share/bash-completion/completions/git ]; then
    source /usr/share/bash-completion/completions/git
fi
' >> "$HOME/.zshrc"
            log_success "Git completion added to ~/.zshrc"
        else
            log_info "Git completion already configured in ~/.zshrc"
        fi
    fi
}

# Main function
main() {
    echo "======================================"
    echo "     Git Completion Setup"
    echo "======================================"
    echo
    
    log_info "Setting up Git branch and command completion..."
    
    # Try to install bash-completion package
    if install_bash_completion; then
        log_success "Package installation completed"
    else
        log_warning "Package installation failed, trying manual installation"
        if install_git_completion_manual; then
            log_success "Manual installation completed"
        else
            log_error "Both package and manual installation failed"
            return 1
        fi
    fi
    
    # Test if completion works
    if test_git_completion; then
        log_success "Git completion is working"
    else
        log_warning "Git completion test failed, but files are installed"
    fi
    
    # Setup shell configuration
    setup_shell_completion
    
    echo
    log_success "Git completion setup completed!"
    echo
    echo "Usage examples after restarting your shell:"
    echo "  git switch feat/<TAB><TAB>  # Shows branches starting with 'feat/'"
    echo "  git checkout <TAB><TAB>     # Shows all branches"
    echo "  git add <TAB><TAB>          # Shows modified files"
    echo "  git log --<TAB><TAB>        # Shows git log options"
    echo
    echo "Restart your shell or run: source ~/.bashrc"
    
    return 0
}

# Run main function
main "$@"
