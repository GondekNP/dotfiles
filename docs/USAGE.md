# Usage Guide

## Claude Code

### Getting Started

Start Claude Code in any project directory:
```bash
cd your-project
claude
```

### Key Features

#### 1. AI-Powered Code Generation
- Ask Claude to write code, explain functions, or debug issues
- Context-aware suggestions based on your codebase
- Multi-language support

#### 2. Interactive Development
```bash
# Check installation and configuration
claude doctor

# Update to latest version
claude update

# Get help
claude --help
```

#### 3. Integration with VS Code
- Works seamlessly alongside GitHub Copilot
- Provides complementary AI assistance
- Access through terminal while coding

### Best Practices

1. **Start with Clear Prompts**: Be specific about what you want
2. **Provide Context**: Share relevant code snippets when asking for help
3. **Iterate**: Refine requests based on Claude's responses
4. **Review Generated Code**: Always review and test AI-generated code

## GitHub Copilot (VS Code)

### Key Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+I` | Generate code with Copilot |
| `Alt+\` | Accept suggestion |
| `Alt+]` | Next suggestion |
| `Alt+[` | Previous suggestion |
| `Ctrl+Shift+P` → "Copilot" | Access Copilot commands |

### Features

#### 1. Code Completion
- Real-time code suggestions as you type
- Context-aware completions
- Multi-line code generation

#### 2. Copilot Chat
- Interactive AI conversations about code
- Explain code functionality
- Generate tests and documentation

#### 3. Code Actions
- Refactor code suggestions
- Bug fix recommendations
- Performance optimizations

### Best Practices

1. **Write Descriptive Comments**: Copilot uses comments for context
2. **Use Meaningful Variable Names**: Helps generate better suggestions
3. **Start Functions with Clear Signatures**: Define parameters and return types
4. **Review Suggestions**: Don't accept everything blindly

## Tmux

### Quick Start

```bash
# Start new session
tmux

# Start named session
tmux new-session -s development

# Attach to existing session
tmux attach -t development

# List sessions
tmux list-sessions
```

### Key Bindings

Our configuration uses `Ctrl+a` as the prefix key.

#### Session Management
| Shortcut | Action |
|----------|--------|
| `Ctrl+a s` | Choose session |
| `Ctrl+a N` | New session |
| `Ctrl+a R` | Rename session |
| `Ctrl+a X` | Kill session |

#### Window Management
| Shortcut | Action |
|----------|--------|
| `Ctrl+a c` | New window |
| `Shift+Left/Right` | Switch windows |
| `Ctrl+a &` | Kill window |

#### Pane Management
| Shortcut | Action |
|----------|--------|
| `Ctrl+a \|` | Split vertically |
| `Ctrl+a -` | Split horizontally |
| `Alt+Arrow` | Navigate panes |
| `Ctrl+Arrow` | Resize panes |
| `Ctrl+a x` | Kill pane |

#### Copy Mode
| Shortcut | Action |
|----------|--------|
| `Ctrl+a [` | Enter copy mode |
| `v` | Start selection |
| `y` | Copy selection |
| `Ctrl+a ]` | Paste |

### Development Workflow

#### 1. Standard Development Setup
```bash
# Create development session with layout
tmux new-session -d -s dev
tmux split-window -h
tmux split-window -v
tmux select-pane -t 0
tmux send-keys 'code .' Enter
tmux select-pane -t 1
tmux send-keys 'claude' Enter
tmux attach -t dev
```

#### 2. Quick Development Command
```bash
# Use the built-in dev function (from aliases)
dev
```

This automatically:
- Opens VS Code in current directory
- Creates tmux session
- Sets up appropriate environment (Node.js, Python, etc.)

#### 3. Pre-configured Layouts
| Shortcut | Layout |
|----------|--------|
| `Alt+1` | Side by side |
| `Alt+2` | Stacked |
| `Alt+3` | Main horizontal |
| `Alt+4` | Main vertical |
| `Alt+5` | Tiled |

### Plugin Usage

#### TPM (Tmux Plugin Manager)
- Install plugins: `Ctrl+a I`
- Update plugins: `Ctrl+a U`
- Uninstall plugins: `Ctrl+a Alt+u`

#### Resurrect (Session Persistence)
- Save session: `Ctrl+a Ctrl+s`
- Restore session: `Ctrl+a Ctrl+r`
- Auto-save every 15 minutes (configured)

## Shell Enhancements

### Aliases

#### Git Aliases
```bash
g         # git
ga        # git add
gc        # git commit
gcm       # git commit -m
gco       # git checkout
gb        # git branch
gs        # git status
gp        # git push
gl        # git pull
glog      # git log --oneline --graph
```

#### Development Aliases
```bash
c         # code
co        # code .
ni        # npm install
ns        # npm start
nt        # npm test
nr        # npm run
py        # python3
```

#### Tmux Aliases
```bash
tm        # tmux
tma       # tmux attach
tmn       # tmux new-session
tml       # tmux list-sessions
tmk       # tmux kill-session
```

### Functions

#### Development Functions
```bash
# Create and enter directory
mkcd project-name

# Start development environment
dev

# Kill development environment
devkill

# Git shortcuts
gcp "commit message"  # add, commit, push
gnb branch-name       # create and checkout branch
gct "message"         # commit with timestamp
```

#### Utility Functions
```bash
# Extract any archive
extract file.zip

# Find files/directories
ff filename
fd dirname

# Quick web server
serve 8000

# System information
sysinfo

# Check port usage
port 3000
```

## Integrated Workflow

### Complete Development Setup

1. **Start Development Session**:
   ```bash
   cd your-project
   dev  # Opens VS Code + tmux session
   ```

2. **In VS Code**:
   - Use GitHub Copilot for code completion
   - Access Git integration
   - Use integrated terminal

3. **In Tmux**:
   - Terminal pane for Claude Code
   - Additional panes for testing, building
   - Easy switching between contexts

4. **Workflow Example**:
   ```bash
   # Pane 1: VS Code
   code .
   
   # Pane 2: Claude Code
   claude
   
   # Pane 3: Development server
   npm run dev
   
   # Pane 4: Testing
   npm test --watch
   ```

### Tips for Maximum Productivity

1. **Use Both AI Assistants**:
   - GitHub Copilot for inline completions
   - Claude Code for complex problem-solving

2. **Leverage Tmux Sessions**:
   - Separate sessions for different projects
   - Persistent sessions survive disconnections

3. **Customize Further**:
   - Modify configs in `~/.dotfiles/config/`
   - Add personal aliases to shell config

4. **Stay Updated**:
   - Regularly update Claude Code: `claude update`
   - Update VS Code extensions
   - Pull dotfiles updates: `cd ~/.dotfiles && git pull`
