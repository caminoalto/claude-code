# Claude Code Devcontainer Starter Template

A comprehensive VS Code devcontainer template optimized for Claude Code development with security-focused networking, modern development tools, and comprehensive language support.

This template is modified from [Anthropic's reference devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) to use a Python base container with Node.js installed, instead of Anthropic's native Node.js Docker image. It includes common requirements.txt, Claude commands, and post-create initialization for Git configuration.

## Features

### 🔧 Development Environment
- **Python 3.11** with pip and common packages
- **Node.js 20** with npm/npx support
- **Claude Code CLI** pre-installed globally
- **Git with delta** for enhanced diff viewing
- **Zsh with Powerlevel10k** theme and useful plugins
- **Network tools** (iptables, curl, ping, nslookup) for firewall configuration

### 🛡️ Security & Networking
- **Configurable firewall** with iptables rules
- **Private network isolation** with selective access
- **DNS configuration** with fallback servers
- **Host network auto-detection** for Docker environments

### 🔌 MCP Servers
- **Context7** - Documentation and library lookup
- **Sequential Thinking** - Advanced reasoning capabilities
- **Playwright** - Browser automation and web testing
- Pre-configured with appropriate permissions

### 🎨 VS Code Integration
- **Essential extensions** pre-installed:
  - Python, PowerShell, JSON support
  - ESLint, Prettier for code formatting
  - Mermaid editor, CSV viewer
  - Resource monitor and more
- **Auto-formatting** on save
- **Integrated terminal** with zsh
- **Persistent volumes** for bash history and Claude config

## Quick Start

### Prerequisites
- [VS Code](https://code.visualstudio.com/) with [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
- [Docker](https://www.docker.com/get-started)

### Setup

1. **Clone or use this template:**
   ```bash
   git clone <your-repo-url>
   cd <your-project>
   ```

2. **Configure environment (optional):**
   ```bash
   cp .env.example .env
   # Edit .env with your preferences
   ```

3. **Open in VS Code:**
   ```bash
   code .
   ```

4. **Reopen in container:**
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and configure

## Configuration

### Environment Variables (.env)

Create a `.env` file in the project root for personalization:

```bash
# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"

# Timezone
TZ="America/New_York"

# Network configuration (optional)
ALLOWED_INBOUND_RANGES="192.168.32.0/24,10.9.0.0/16"
ALLOWED_OUTBOUND_PRIVATE_RANGES="10.0.0.0/8,192.168.24.0/23"
DNS_SERVERS="192.168.16.1,8.8.8.8"
```

### Python Dependencies

Add your Python packages to `requirements.txt`:

```txt
requests
pandas
numpy
# Add your packages here
```

### Claude Configuration

The devcontainer includes:
- Claude Code CLI globally installed
- MCP servers (Context7, Sequential Thinking) pre-configured
- Persistent Claude configuration in `~/.claude`

## File Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json      # Main devcontainer configuration
│   ├── Dockerfile            # Container image definition
│   ├── post-create.sh        # Post-creation setup script
│   └── init-firewall.sh      # Network security configuration
├── .claude/
│   └── settings.local.json   # Claude Code settings
├── .gitignore               # Comprehensive gitignore
├── .gitattributes          # Git file handling rules
├── .mcp.json               # MCP server configuration
└── README.md               # This file
```

## Network Security

The devcontainer includes a sophisticated firewall configuration:

### Inbound Rules
- Allows connections from specified private network ranges
- Auto-detects and allows Docker host network
- Blocks all other inbound connections

### Outbound Rules
- Allows connections to specified private network ranges
- Allows all public internet access
- Blocks access to other private networks (security isolation)
- Preserves DNS functionality

### Customization
Override network settings via environment variables in `.env`:

```bash
# Allow inbound from these ranges
ALLOWED_INBOUND_RANGES="10.0.0.0/8,192.168.0.0/16"

# Allow outbound to these private ranges
ALLOWED_OUTBOUND_PRIVATE_RANGES="10.0.0.0/8"

# Additional DNS servers
DNS_SERVERS="8.8.8.8,1.1.1.1"
```

## VS Code Extensions

The following extensions are pre-installed:

- **Language Support:** Python, PowerShell, JSON
- **Code Quality:** ESLint, Prettier
- **Development Tools:** Makefile Tools, Resource Monitor
- **Utilities:** Mermaid Editor, Rainbow CSV
- **Claude Integration:** Claude Code extension

## Persistent Data

The devcontainer uses volumes for persistence:

- **Command History:** `claude-code-bashhistory` volume
- **Claude Config:** `claude-code-config` volume mounted to `~/.claude`

## Troubleshooting

### Network Issues
- Check firewall rules: `sudo iptables -L -n -v`
- Test connectivity: `curl -I https://github.com`
- Review DNS: `cat /etc/resolv.conf`

### Python Package Issues
- Verify installation: `pip list`
- Reinstall packages: `pip install -r requirements.txt --force-reinstall`

### Claude Code Issues
- Check installation: `claude --version`
- Verify MCP servers: `claude mcp list`
- Review configuration: `cat ~/.claude/settings.local.json`

## Customization

### Adding New Tools
Edit `.devcontainer/Dockerfile` to add new packages:

```dockerfile
RUN apt update && apt install -y \
  your-package-here
```

### Adding VS Code Extensions
Update `devcontainer.json`:

```json
"extensions": [
  "existing.extensions",
  "your.new.extension"
]
```

### Modifying MCP Servers
Edit `.mcp.json` and `.claude/settings.local.json` to add/remove MCP servers.

## Usage as Template

This is a GitHub template repository. Click "Use this template" to create a new repository with this devcontainer setup.

## License

This template is provided as-is for development use. Customize according to your project's license requirements.

---

**Happy coding with Claude!** 🚀