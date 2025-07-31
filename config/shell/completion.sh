#!/bin/bash
# Git Completion Setup for Development
# Provides Git branch and command completion without aliases

# ===== COMPLETION ENHANCEMENTS =====

# Enable programmable completion features
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# Git completion setup
setup_git_completion() {
    # Try different locations for git completion
    local git_completion_paths=(
        "/usr/share/bash-completion/completions/git"
        "/etc/bash_completion.d/git"
        "/usr/local/etc/bash_completion.d/git-completion.bash"
        "/opt/homebrew/etc/bash_completion.d/git-completion.bash"
        "$HOME/.git-completion.bash"
    )
    
    for completion_path in "${git_completion_paths[@]}"; do
        if [ -f "$completion_path" ]; then
            # shellcheck source=/dev/null
            source "$completion_path"
            break
        fi
    done
}

# Install git completion if not available
install_git_completion() {
    if ! type __git_complete &>/dev/null; then
        echo "Installing Git completion..."
        
        # Download git completion script
        local completion_url="https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash"
        local completion_file="$HOME/.git-completion.bash"
        
        if command -v curl &>/dev/null; then
            curl -o "$completion_file" "$completion_url" 2>/dev/null
        elif command -v wget &>/dev/null; then
            wget -O "$completion_file" "$completion_url" 2>/dev/null
        fi
        
        if [ -f "$completion_file" ]; then
            # shellcheck source=/dev/null
            source "$completion_file"
            echo "Git completion installed successfully"
        fi
    fi
}

# Set up Git completion
if [ -n "$BASH_VERSION" ]; then
    setup_git_completion
    
    # If completion not found, try to install it
    if ! type __git_complete &>/dev/null; then
        install_git_completion
        setup_git_completion
    fi
fi

# ===== PATH ENHANCEMENTS =====

# Add local bin to PATH if it exists
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add npm global bin to PATH if it exists
if command -v npm &> /dev/null; then
    NPM_PREFIX=$(npm config get prefix 2>/dev/null || echo "$HOME/.npm-global")
    if [ -d "$NPM_PREFIX/bin" ]; then
        export PATH="$NPM_PREFIX/bin:$PATH"
    fi
fi

# ===== ENVIRONMENT VARIABLES =====

# Editor preferences
export EDITOR='code'
export VISUAL='code'

# History settings
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:ignorespace

# Colors for ls
if command -v dircolors &> /dev/null; then
    eval "$(dircolors -b)"
fi
