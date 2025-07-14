# Changelog

## [0.2.0] - 2024-07-14

### Added

- Docker-Outside-of-Docker feature and docker-compose.yml to allow provisioning of additional containers alongside the devcontainer
- Optional common Devcontainer features and extensions
- Dynamic container naming implementation using COMPOSE_PROJECT_NAME to support template reuse

### Changed

- Enhanced container initialization process to ensure environment variables are used for firewalls and allow deployment-specific provisioning
- Fixed workspace folder path configuration in Docker Compose

## [0.1.0] - 2024-07-11

Complete devcontainer setup with Python 3.11 + Node.js 20, security-focused networking, and pre-configured MCP servers.

### Features

- Python 3.11 and Node.js 20 development environment
- Configurable iptables firewall with network isolation
- Pre-configured MCP servers (Context7, Sequential Thinking, Playwright)
- VS Code integration with essential extensions
- Dynamic folder name support for template usage
- Comprehensive documentation and setup instructions
