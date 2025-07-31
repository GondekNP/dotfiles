# Installation Guide

## Prerequisites

Before running the installation script, ensure you have:

### Required Software
- **Node.js 18+** - Required for Claude Code
  ```bash
  # Ubuntu/Debian
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get install -y nodejs
  
  # macOS
  brew install node
  ```

- **Git** - For repository management
  ```bash
  # Ubuntu/Debian
  sudo apt-get install git
  
  # macOS (usually pre-installed)
  git --version
  ```

- **curl** - For downloading packages
  ```bash
  # Ubuntu/Debian
  sudo apt-get install curl
  
  # macOS (usually pre-installed)
  curl --version
  ```

### System Requirements
- **OS**: Ubuntu 20.04+, Debian 10+, or macOS 10.15+
- **RAM**: 4GB+ (recommended for Claude Code)
- **Network**: Internet connection for downloads and authentication

## Installation Methods

### Method 1: Automated Installation (Recommended)

Clone and run the installation script:

```bash
git clone https://github.com/GondekNP/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

This will install all components in the correct order with proper error handling.

### Method 2: Manual Component Installation

If you prefer to install components individually:

```bash
cd ~/.dotfiles

# Install Claude Code
./scripts/install-claude.sh

# Install VS Code & GitHub Copilot
./scripts/install-vscode.sh

# Install Tmux
./scripts/install-tmux.sh
```

### Method 3: Selective Installation

Install only specific components by running individual scripts:

```bash
# Only Claude Code
./scripts/install-claude.sh

# Only VS Code setup
./scripts/install-vscode.sh

# Only Tmux setup
./scripts/install-tmux.sh
```

## Post-Installation Setup

### 1. Claude Code Authentication

After installation, authenticate Claude Code:

```bash
# Start Claude Code in a project directory
cd your-project
claude
```

Choose your authentication method:
- **Anthropic Console** (requires billing)
- **Claude App** (Pro/Max subscription)
- **Enterprise** (Bedrock/Vertex AI)

### 2. GitHub Copilot Setup

1. Open VS Code
2. Sign in to GitHub: `Ctrl+Shift+P` → "GitHub: Sign In"
3. Ensure you have a GitHub Copilot subscription
4. Restart VS Code

### 3. Tmux Configuration

The tmux configuration is automatically applied. To install plugins:

1. Start tmux: `tmux`
2. Install plugins: `Ctrl+a I` (capital i)
3. Refresh environment: `Ctrl+a r`

## Verification

### Check Claude Code
```bash
claude --version
claude doctor
```

### Check VS Code Extensions
```bash
code --list-extensions | grep -E "(copilot|github)"
```

### Check Tmux
```bash
tmux -V
tmux list-sessions
```

## Troubleshooting

### Common Issues

#### 1. Node.js Permission Errors
```bash
# Fix npm global permissions
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

#### 2. VS Code Not Found
```bash
# Ubuntu/Debian: Re-install VS Code
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update
sudo apt install code
```

#### 3. Tmux Plugin Installation Issues
```bash
# Reinstall TPM
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

#### 4. Claude Code Command Not Found
```bash
# Add to PATH manually
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Getting Help

1. **Claude Code Issues**: https://docs.anthropic.com/en/docs/claude-code/troubleshooting
2. **GitHub Copilot Issues**: Check VS Code extension settings
3. **Tmux Issues**: Check `~/.tmux.conf` syntax with `tmux source-file ~/.tmux.conf`

## Updating

### Update All Components
```bash
cd ~/.dotfiles
git pull
./install.sh
```

### Update Individual Components
```bash
# Update Claude Code
claude update

# Update VS Code extensions
code --update-extensions

# Update tmux plugins
tmux run '~/.tmux/plugins/tpm/bin/update_plugins all'
```

## Uninstallation

### Remove Claude Code
```bash
npm uninstall -g @anthropic-ai/claude-code
```

### Remove VS Code Extensions
```bash
code --uninstall-extension GitHub.copilot
code --uninstall-extension GitHub.copilot-chat
```

### Remove Configurations
```bash
# Remove tmux config
rm ~/.tmux.conf
rm -rf ~/.tmux/

# Remove VS Code settings (backup first!)
rm -rf ~/.config/Code/User/settings.json
rm -rf ~/.config/Code/User/keybindings.json
```
