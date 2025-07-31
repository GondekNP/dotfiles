# Dotfiles Repository

A comprehensive dotfiles setup that includes:
- 🤖 **Claude Code** - AI-powered coding assistant
- 🐙 **GitHub Copilot** - AI pair programmer extensions for VS Code
- 🌿 **Git Repository Autocomplete** - Branch and command completion
- 🖥️ **Tmux** - Terminal multiplexer for enhanced productivity
- ⚙️ **VS Code Extensions** - Essential development tools (devcontainer-ready)

## Quick Start

```bash
git clone https://github.com/GondekNP/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

## What's Included

### Core Tools
- **Claude Code**: AI coding assistant with advanced capabilities
- **GitHub Copilot**: VS Code extensions for AI-powered code completion
- **Git Completion**: Branch and command autocomplete (git switch feat/<TAB>)
- **Tmux**: Terminal multiplexer with custom configuration

### VS Code Extensions (Devcontainer-Ready)
- GitHub Copilot & Copilot Chat
- GitHub Pull Requests & Issues
- GitLens - Git supercharged
- Essential development extensions
- Productivity enhancers

### Shell Configuration
- Git branch completion
- PATH management
- Basic environment setup

## Structure

```
dotfiles/
├── install.sh              # Main installation script
├── scripts/                 # Installation scripts
│   ├── install-claude.sh    # Claude Code setup
│   ├── install-vscode.sh    # VS Code extensions & config
│   ├── install-git-completion.sh # Git autocomplete setup
│   └── install-tmux.sh      # Tmux installation & config
├── config/                  # Configuration files
│   ├── vscode/              # VS Code settings
│   ├── tmux/                # Tmux configuration
│   └── shell/               # Shell configurations
└── docs/                    # Documentation
```

## Prerequisites

- Node.js 18+ (for Claude Code)
- Git
- Ubuntu 20.04+/Debian 10+ or macOS 10.15+
- Internet connection

## Manual Installation

If you prefer to install components individually:

```bash
# Install Claude Code
./scripts/install-claude.sh

# Install VS Code extensions & configuration
./scripts/install-vscode.sh

# Install Git repository autocomplete
./scripts/install-git-completion.sh

# Install Tmux with configuration
./scripts/install-tmux.sh
```

## Configuration

### Claude Code
- Automatic setup with authentication prompts
- Configured for optimal VS Code integration

### GitHub Copilot
- Auto-configured extensions for VS Code
- Requires GitHub account with Copilot subscription
- Works in devcontainers

### Git Repository Autocomplete
- Branch name completion: `git switch feat/<TAB>`
- Command completion: `git <TAB><TAB>`
- File completion: `git add <TAB><TAB>`

### Tmux
- Custom key bindings
- Enhanced status bar
- Mouse support enabled

## Troubleshooting

See individual script documentation in `docs/` for specific issues.

## License

MIT License - see LICENSE file for details.
