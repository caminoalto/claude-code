# Claude Code Devcontainer Starter Template

A comprehensive VS Code devcontainer template optimized for Claude Code development with security-focused networking, modern development tools, and modular architecture using Docker Compose.

This template is adapted from the [Claude Code reference implementation](https://github.com/anthropics/claude-code) and uses a **hybrid approach** for tool management: essential development tools are built into the base container, while cloud-specific tools are available as optional DevContainer features that users can enable as needed.

## Features

### 🔧 Core Development Environment

- **Python 3.11** with pip and common packages
- **Node.js 20** with npm/npx support
- **Claude Code CLI** pre-installed globally
- **Git with delta** for enhanced diff viewing
- **Zsh with Powerlevel10k** theme and useful plugins
- **Docker-Outside-of-Docker** - Use host Docker daemon
- **Network tools** (iptables, ipset, curl, ping, nslookup) for firewall configuration

### ⚡ Optional Cloud Features

Choose from these DevContainer features by uncommenting in `devcontainer.json`:

- **PowerShell** - Cross-platform PowerShell support
- **Azure CLI + Bicep** - Azure development tools
- **Azure Developer CLI (azd)** - Modern Azure development workflow
- **Azure Functions** - Serverless development tools
- **Terraform** - Infrastructure as code
- **AWS CLI** - Amazon Web Services tools
- **SQL Server** - Database development tools

### 🛡️ Security & Networking

- **Configurable firewall** with iptables rules
- **Private network isolation** with selective access (including 172.16.0.0/12)
- **Interactive DNS configuration** during setup
- **Host network auto-detection** for Docker environments
- **Modular setup scripts** for environment, security, infrastructure, and application

### 🔌 MCP Servers

- **Context7** - Documentation and library lookup
- **Sequential Thinking** - Advanced reasoning capabilities
- **Playwright** - Browser automation and web testing
- Pre-configured with appropriate permissions

### 🎨 VS Code Integration

- **Core extensions** always included:
  - Python, JSON support, ESLint, Prettier
  - Mermaid editor, CSV viewer, Resource monitor
  - Claude Code extension
- **Optional extensions** for cloud features:
  - PowerShell, Bicep, Azure tools
  - Terraform, AWS Toolkit, Docker support
  - SQL Server tools
- **Auto-formatting** on save with configurable settings
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

2. **Open in VS Code:**

   ```bash
   code .
   ```

3. **Reopen in container:**

   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Select "Dev Containers: Reopen in Container"
   - Wait for the container to build and configure

4. **Interactive setup:**

   - If no `.env` file exists, you'll be prompted to configure:
     - Git user name and email
     - Custom DNS servers (optional)
   - The setup will create project structure (`src/`, `tests/`, `docs/`)
   - Install Python packages from `requirements.txt` or fallback defaults

5. **Enable optional features (optional):**
   - Edit `.devcontainer/devcontainer.json`
   - Uncomment desired features in the `features` section
   - Uncomment corresponding VS Code extensions
   - Rebuild container to apply changes

## Configuration

### Environment Variables (.env)

The template supports both automatic and manual configuration:

**Automatic (Recommended):**

- If no `.env` file exists, you'll be prompted during container setup
- Interactive prompts for project name, Git credentials and DNS servers
- Sensible defaults with option to customize

**Manual:**
Create a `.env` file in the project root:

```bash
# Project Configuration
COMPOSE_PROJECT_NAME="claude-code"

# Git configuration
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"

# Timezone
TZ="America/New_York"

# Network configuration (includes all private ranges)
ALLOWED_INBOUND_RANGES="192.168.1.0/24,10.0.0.0/16,172.16.0.0/12"
ALLOWED_OUTBOUND_PRIVATE_RANGES="10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
DNS_SERVERS="192.168.1.1,8.8.8.8"
```

### Python Dependencies

The template includes essential packages by default:

```txt
requests==2.32.4      # HTTP library
python-dotenv==1.1.1  # Environment variable loading
click==8.2.1           # Command-line interface creation
pytest==8.4.1         # Testing framework
netaddr==1.3.0         # Network address manipulation
```

Add your project-specific packages to `requirements.txt`:

```txt
# Add your packages here
pandas
numpy
fastapi
# etc.
```

### Claude Configuration

The devcontainer includes:

- Claude Code CLI globally installed
- MCP servers (Context7, Sequential Thinking, Playwright) pre-configured
- Smart batch commit workflow (`.claude/commands/commit.md`)
- Persistent Claude configuration in `~/.claude` (user-specific, not tracked)

### Optional Features

Enable cloud-specific tools by uncommenting in `.devcontainer/devcontainer.json`:

```json
"features": {
  // Core development tools
  "ghcr.io/devcontainers/features/powershell:1": {},

  // Azure development
  "ghcr.io/devcontainers/features/azure-cli:1": {
    "installBicep": true
  },
  "ghcr.io/azure/azure-dev/azd:latest": {},

  // Other cloud tools
  "ghcr.io/devcontainers/features/terraform:1": {},
  "ghcr.io/devcontainers/features/aws-cli:1": {}
}
```

Also uncomment corresponding VS Code extensions for full integration.

## Architecture

### Multi-Container Setup

The template uses **Docker Compose** for flexible container orchestration:

- **Dynamic project naming** prevents conflicts when using the template multiple times
- **Persistent volumes** for bash history and Claude configuration
- **Network isolation** with configurable firewall rules
- **Modular setup scripts** for different configuration phases

### Setup Workflow

The container setup follows a **4-step process**:

1. **01-environment-setup.sh** - Environment & Git configuration with interactive prompts
2. **02-security-setup.sh** - Firewall & network security configuration
3. **03-infrastructure-setup.sh** - **[Placeholder]** for external services (databases, etc.)
4. **04-application-setup.sh** - Python packages, project structure, and development tools

## File Structure

```
.
├── .devcontainer/
│   ├── devcontainer.json          # Main devcontainer configuration with optional features
│   ├── docker-compose.yml         # Multi-container orchestration
│   ├── Dockerfile                 # Lean container image definition
│   ├── 01-environment-setup.sh    # Interactive environment & Git setup
│   ├── 02-security-setup.sh       # Firewall & network security
│   ├── 03-infrastructure-setup.sh # Placeholder for external services
│   ├── 04-application-setup.sh    # Python packages & project structure
│   └── setup.sh                   # Main setup orchestrator
├── .claude/
│   └── commands/
│       └── commit.md            # Smart batch commit workflow for Claude Code
├── .gitignore                   # Comprehensive gitignore
├── .gitattributes               # Git file handling rules
├── .mcp.json                    # MCP server configuration
├── .env.example                 # Environment template with all private IP ranges
├── requirements.txt             # Python package dependencies
└── README.md                    # This file
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
# Allow inbound from these ranges (includes all private IP ranges)
ALLOWED_INBOUND_RANGES="192.168.1.0/24,10.0.0.0/16,172.16.0.0/12"

# Allow outbound to these private ranges (includes Docker networks)
ALLOWED_OUTBOUND_PRIVATE_RANGES="10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"

# Additional DNS servers (configured interactively or manually)
DNS_SERVERS="192.168.1.1,8.8.8.8"
```

## VS Code Extensions

The template uses a **hybrid approach** for extensions:

### Core Extensions (Always Included)

- **Language Support:** Python, JSON
- **Code Quality:** ESLint, Prettier
- **Development Tools:** Makefile Tools, Resource Monitor
- **Utilities:** Mermaid Editor, Rainbow CSV
- **Claude Integration:** Claude Code extension

### Optional Extensions (Uncomment as needed)

- **PowerShell:** Cross-platform PowerShell support
- **Azure Tools:** Bicep, Azure Developer CLI, Azure Functions
- **Docker:** Docker container management
- **Terraform:** Infrastructure as code support
- **AWS:** AWS Toolkit for VS Code
- **SQL Server:** Database development tools

Users can enable optional extensions by uncommenting them in the `extensions` array in `devcontainer.json`.

## Persistent Data

The devcontainer uses **dynamic volumes** for persistence:

- **Command History:** `{project-name}-bashhistory` volume
- **Claude Config:** `{project-name}-config` volume mounted to `~/.claude`

Volume names are automatically generated based on your project folder name, preventing conflicts when using the template multiple times.

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

For cloud-specific tools, use DevContainer features (recommended):

```json
"features": {
  "ghcr.io/devcontainers/features/your-tool:1": {}
}
```

For system packages, edit `.devcontainer/Dockerfile.new`:

```dockerfile
RUN apt update && apt install -y \
  your-package-here
```

### Adding VS Code Extensions

Uncomment optional extensions or add new ones in `devcontainer.json`:

```json
"extensions": [
  // Optional extensions - uncomment as needed
  // "your.new.extension",

  // Core extensions (always included)
  "existing.extensions"
]
```

### Adding Infrastructure Services

Use the infrastructure setup placeholder:

1. Add services to `docker-compose.yml`
2. Update `03-infrastructure-setup.sh` with initialization logic
3. Add environment variables to `.env.example`

### Modifying MCP Servers

Edit `.mcp.json` and `.claude/settings.local.json` to add/remove MCP servers.

## Usage as Template

This is a GitHub template repository designed for **multiple deployments**:

### Template Features

- **Conflict-free deployment** - Dynamic naming prevents Docker conflicts
- **Modular architecture** - Easy to customize for different project types
- **Hybrid tool approach** - Core tools included, optional features available
- **Interactive setup** - Guided configuration for new users
- **Extensible design** - Infrastructure placeholder for complex projects

### Getting Started

1. Click "Use this template" to create a new repository
2. Clone your new repository locally
3. Open in VS Code and reopen in container
4. Follow the interactive setup prompts
5. Enable optional features as needed for your project

### Multiple Instances

You can deploy this template multiple times without conflicts:

- Each project gets unique Docker container names
- Persistent volumes are project-specific
- Network configurations are isolated per project

## License

This template is provided as-is for development use. Customize according to your project's license requirements.

---

**Happy coding with Claude!** 🚀
