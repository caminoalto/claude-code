# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code devcontainer starter template designed to provide a comprehensive development environment with security-focused networking, modern development tools, and pre-configured MCP servers.

## Architecture Overview

This template uses a multi-layered approach:

**Container Layer (.devcontainer/)**
- `Dockerfile`: Python 3.11 + Node.js 20 base with development tools and network utilities
- `devcontainer.json`: VS Code configuration with extensions, mounts, and environment
- `post-create.sh`: Post-container setup script for Python packages and Git configuration
- `init-firewall.sh`: Sophisticated iptables-based network security configuration

**Claude Integration**
- `.mcp.json`: Defines available MCP servers (Context7, Sequential Thinking, Playwright)
- `.claude/settings.local.json`: Claude Code permissions and enabled MCP servers
- `.claude/commands/commit.md`: Smart batch commit workflow for organizing changes

**Security Model**
The firewall script implements network isolation:
- Inbound: Only from specified private ranges + Docker host network
- Outbound: Allows public internet, blocks private networks except specified ranges
- Environment variables control allowed network ranges

## Essential Commands

### Container Management
```bash
# Build and start the devcontainer
# Use VS Code Command Palette: "Dev Containers: Reopen in Container"

# Check firewall status after container starts
sudo iptables -L -n -v

# Test network connectivity
curl -I https://github.com
```

### Network Configuration
```bash
# Firewall is automatically configured during container startup
# Override network settings via environment variables in .env:
ALLOWED_INBOUND_RANGES="192.168.32.0/24,10.9.0.0/16"
ALLOWED_OUTBOUND_PRIVATE_RANGES="10.0.0.0/8,192.168.24.0/23"
DNS_SERVERS="192.168.16.1,8.8.8.8"
```

### Claude Code Operations
```bash
# Check Claude installation
claude --version

# List available MCP servers
claude mcp list

# Use the smart batch commit workflow
# Reference: .claude/commands/commit.md
```

### Development Setup
```bash
# Environment configuration (optional)
cp .env.example .env
# Edit .env with Git credentials and preferences

# Python packages are auto-installed via post-create.sh
# Add packages to requirements.txt for automatic installation
```

## Key Configuration Files

**Network Security**: `init-firewall.sh` contains the core security logic with configurable IP ranges
**MCP Integration**: Three servers pre-configured - Context7 (docs), Sequential Thinking (reasoning), Playwright (browser automation)
**Git Integration**: Automatic Git configuration from .env variables during container setup
**Persistence**: Bash history and Claude config stored in Docker volumes

## Template Customization

This template uses a **hybrid approach** for tool management:

### **Built-in Tools (Always Available)**
- **Core Development**: Python 3.11, Node.js 20, Git, Claude Code
- **Utilities**: curl, wget, jq, fzf, zsh, build-essential
- **Container**: Docker with socket access
- **Security**: iptables, ipset, firewall scripts

### **Optional Features (Opt-in)**
Cloud-specific tools are available as DevContainer features. To enable them, uncomment the relevant sections in `.devcontainer/devcontainer.json`:

```json
"features": {
  "ghcr.io/devcontainers/features/azure-cli:1": {},           // Azure CLI
  "ghcr.io/azure/azure-dev/azd:latest": {},                   // Azure Developer CLI
  "ghcr.io/devcontainers/features/aws-cli:1": {},             // AWS CLI  
  "ghcr.io/devcontainers/features/terraform:1": {},           // Terraform
  "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {} // Kubernetes tools
}
```

### **Customization Steps**
1. **Network Configuration**: Adjust allowed IP ranges in .env for your environment
2. **Python Dependencies**: Add packages to requirements.txt
3. **VS Code Extensions**: Modify devcontainer.json extensions array
4. **Optional Features**: Uncomment needed cloud tools in features section
5. **MCP Servers**: Update .mcp.json and .claude/settings.local.json for additional servers
6. **Security**: The firewall blocks private network access by default - explicitly allow ranges needed

## File Structure Patterns

- `.devcontainer/`: Complete container definition and setup scripts
- `.claude/`: Claude Code configuration and command workflows
- Root level: Git configuration files (.gitignore, .gitattributes) and documentation

This template prioritizes security (network isolation), development experience (pre-configured tools), and Claude Code integration (MCP servers and workflows).