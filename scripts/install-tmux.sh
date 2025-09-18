#!/bin/bash

# Tmux Installation and Configuration Script
# Installs tmux with custom configuration for enhanced productivity

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

# Check if tmux is already installed
check_tmux_installation() {
    if command -v tmux &> /dev/null; then
        TMUX_VERSION=$(tmux -V)
        log_success "Tmux is already installed: $TMUX_VERSION"
        return 0
    else
        log_info "Tmux not found, will install"
        return 1
    fi
}

# Build tmux from source in user space
install_tmux_from_source() {
    log_info "Building tmux from source in user directory..."

    local TMUX_VERSION="3.3a"
    local BUILD_DIR="$HOME/.local/src"
    local INSTALL_DIR="$HOME/.local"

    # Create directories
    mkdir -p "$BUILD_DIR" "$INSTALL_DIR"

    # Check for required build tools
    if ! command -v gcc &> /dev/null || ! command -v make &> /dev/null; then
        log_error "Build tools (gcc, make) not found. Cannot build from source."
        log_info "In most devcontainers, tmux should be pre-installed."
        return 1
    fi

    cd "$BUILD_DIR"

    # Download tmux source
    log_info "Downloading tmux source..."
    if command -v curl &> /dev/null; then
        curl -L "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" | tar -xz
    elif command -v wget &> /dev/null; then
        wget -qO- "https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz" | tar -xz
    else
        log_error "Neither curl nor wget available to download tmux"
        return 1
    fi

    cd "tmux-${TMUX_VERSION}"

    # Configure and build
    log_info "Configuring and building tmux..."
    ./configure --prefix="$INSTALL_DIR" 2>/dev/null
    make -j$(nproc) 2>/dev/null
    make install 2>/dev/null

    # Add to PATH if not already there
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Clean up
    cd && rm -rf "$BUILD_DIR/tmux-${TMUX_VERSION}"

    log_success "Tmux built and installed to ~/.local/bin"
}

# Install tmux on macOS
install_tmux_macos() {
    log_info "Installing tmux on macOS..."
    
    if command -v brew &> /dev/null; then
        brew install tmux
        log_success "Tmux installed via Homebrew"
    else
        log_error "Homebrew not found. Please install Homebrew first:"
        log_info "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        return 1
    fi
}

# Install tmux based on OS
install_tmux() {
    if check_tmux_installation; then
        return 0
    fi

    # In containers, tmux is usually pre-installed
    log_warning "Tmux not found. In container environments, it should be pre-installed."

    case "$OSTYPE" in
        linux-gnu*)
            log_info "Attempting to build tmux from source..."
            if install_tmux_from_source; then
                return 0
            else
                log_error "Failed to build tmux from source"
                log_info "Please contact your system administrator to install tmux"
                return 1
            fi
            ;;
        darwin*)
            install_tmux_macos
            ;;
        *)
            log_error "Unsupported operating system: $OSTYPE"
            return 1
            ;;
    esac
}

# Create tmux configuration
create_tmux_config() {
    log_info "Creating tmux configuration..."
    
    # Use custom config if available, otherwise create a default one
    if [ -f "$DOTFILES_DIR/config/tmux/.tmux.conf" ]; then
        cp "$DOTFILES_DIR/config/tmux/.tmux.conf" "$HOME/.tmux.conf"
        log_success "Custom tmux configuration applied"
    else
        # Create default tmux configuration
        cat > "$HOME/.tmux.conf" << 'EOF'
# Tmux Configuration
# Optimized for development productivity

# Set prefix key to Ctrl-a (easier than Ctrl-b)
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

# Enable mouse support
set -g mouse on

# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Increase scrollback buffer size
set -g history-limit 10000

# Use 256 colors
set -g default-terminal "screen-256color"

# Enable activity alerts
setw -g monitor-activity on
set -g visual-activity on

# Split panes using | and -
bind | split-window -h
bind - split-window -v
unbind '"'
unbind %

# Reload config file
bind r source-file ~/.tmux.conf \; display-message "Config reloaded!"

# Switch panes using Alt-arrow without prefix
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Enable vi mode
setw -g mode-keys vi

# Copy mode bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection
bind-key -T copy-mode-vi r send-keys -X rectangle-toggle

# Status bar configuration
set -g status-bg black
set -g status-fg white
set -g status-interval 60
set -g status-left-length 30
set -g status-left '#[fg=green](#S) #(whoami)'
set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=white]%H:%M#[default]'

# Pane border colors
set -g pane-border-style fg=black
set -g pane-active-border-style fg=brightgreen

# Window status colors
setw -g window-status-current-style fg=brightred,bg=black,bold
setw -g window-status-style fg=white,bg=black

# Command/message line colors
set -g message-style fg=black,bg=brightgreen

# Don't exit tmux when last shell exits
set -g exit-empty off

# Increase escape time for better vim experience
set -sg escape-time 0

# Enable focus events for vim
set -g focus-events on
EOF
        log_success "Default tmux configuration created"
    fi
}

# Install Tmux Plugin Manager (optional)
install_tmux_plugin_manager() {
    log_info "Installing Tmux Plugin Manager..."
    
    TPM_DIR="$HOME/.tmux/plugins/tpm"
    
    if [ -d "$TPM_DIR" ]; then
        log_warning "TPM already installed, updating..."
        cd "$TPM_DIR" && git pull
    else
        git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
        log_success "Tmux Plugin Manager installed"
    fi
    
    # Add TPM to tmux config if not already present
    if ! grep -q "tmux-plugins/tpm" "$HOME/.tmux.conf"; then
        cat >> "$HOME/.tmux.conf" << 'EOF'

# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'
EOF
        log_success "TPM configuration added to tmux.conf"
    fi
}

# Main installation function
main() {
    echo "======================================"
    echo "      Tmux Installation & Setup"
    echo "======================================"
    echo
    
    # Install tmux
    if install_tmux; then
        log_success "Tmux installation completed"
    else
        log_error "Tmux installation failed"
        return 1
    fi
    
    # Create configuration
    create_tmux_config
    
    # Install plugin manager
    install_tmux_plugin_manager
    
    echo
    log_success "Tmux setup completed!"
    echo
    echo "Usage:"
    echo "• Start tmux: tmux"
    echo "• Attach to session: tmux attach" 
    echo "• New session: tmux new-session"
    echo "• List sessions: tmux list-sessions"
    echo "• Kill session: tmux kill-session"
    echo
    echo "Key bindings:"
    echo "• Prefix: Ctrl-a"
    echo "• Split vertical: Ctrl-a |"
    echo "• Split horizontal: Ctrl-a -"
    echo "• Navigate panes: Alt + Arrow keys"
    echo "• Reload config: Ctrl-a r"
    echo
    echo "Install plugins: Ctrl-a I (after starting tmux)"
    
    return 0
}

# Run main function
main "$@"
