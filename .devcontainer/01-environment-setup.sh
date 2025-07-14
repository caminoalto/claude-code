#!/bin/bash
set -euo pipefail

echo "🔧 STEP 1: Environment & Configuration Setup"
echo "=============================================="

# Initialize .env file if it doesn't exist
if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"

    # Prompt for Project Name
    echo ""
    echo "🏗️  Project Configuration Setup"
    echo "Please enter your project name (used for container naming):"
    read -p "Project Name [claude-code]: " project_name
    
    # Use default if empty
    if [ -z "$project_name" ]; then
        project_name="claude-code"
    fi
    
    # Update .env file with project name
    sed -i "s/PROJECT_NAME=\"claude-code\"/PROJECT_NAME=\"$project_name\"/" .env
    echo "✅ Updated .env with project name: $project_name"

    # Prompt for Git configuration
    echo ""
    echo "🔧 Git Configuration Setup"
    echo "Please enter your Git configuration details:"

    read -p "Git User Name: " git_name
    read -p "Git User Email: " git_email

    if [ -n "$git_name" ] && [ -n "$git_email" ]; then
        # Update .env file with user input
        sed -i "s/GIT_USER_NAME=\"Your Name\"/GIT_USER_NAME=\"$git_name\"/" .env
        sed -i "s/GIT_USER_EMAIL=\"your.email@example.com\"/GIT_USER_EMAIL=\"$git_email\"/" .env
        echo "✅ Updated .env with Git configuration"
    else
        echo "⚠️  Git configuration skipped - you can edit .env manually later"
    fi

    # Prompt for DNS servers configuration
    echo ""
    echo "🌐 DNS Configuration Setup"
    echo "Current DNS servers in .env.example: 192.168.1.1,8.8.8.8"
    echo "Enter custom DNS servers (comma-separated) or press Enter to keep defaults:"
    read -p "DNS Servers: " dns_servers

    if [ -n "$dns_servers" ]; then
        # Update .env file with custom DNS servers
        sed -i "s/DNS_SERVERS=\"192.168.1.1,8.8.8.8\"/DNS_SERVERS=\"$dns_servers\"/" .env
        echo "✅ Updated .env with custom DNS servers: $dns_servers"
    else
        echo "✅ Using default DNS servers: 192.168.1.1,8.8.8.8"
    fi
fi

# Validate .env file exists
if [ ! -f .env ]; then
    echo "❌ ERROR: .env file not found and .env.example not available"
    exit 1
fi

# Load and validate environment variables
if [ -f .env ]; then
    source .env
    echo "✅ Environment variables loaded from .env"

    # Validate required firewall configuration
    if [ -z "${ALLOWED_INBOUND_RANGES:-}" ]; then
        echo "❌ ERROR: ALLOWED_INBOUND_RANGES not set in .env"
        exit 1
    fi

    if [ -z "${ALLOWED_OUTBOUND_PRIVATE_RANGES:-}" ]; then
        echo "❌ ERROR: ALLOWED_OUTBOUND_PRIVATE_RANGES not set in .env"
        exit 1
    fi

    if [ -z "${DNS_SERVERS:-}" ]; then
        echo "❌ ERROR: DNS_SERVERS not set in .env"
        exit 1
    fi

    echo "✅ Required firewall configuration validated"
fi

# Configure Git if not already set and .env file exists
if [ -f .env ]; then
    source .env

    # Only set git config if not already configured
    if [ -z "$(git config --global user.name)" ] && [ -n "$GIT_USER_NAME" ]; then
        git config --global user.name "$GIT_USER_NAME"
        echo "✅ Git user.name set to: $GIT_USER_NAME"
    fi

    if [ -z "$(git config --global user.email)" ] && [ -n "$GIT_USER_EMAIL" ]; then
        git config --global user.email "$GIT_USER_EMAIL"
        echo "✅ Git user.email set to: $GIT_USER_EMAIL"
    fi
fi

# Set up global git settings
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global pull.rebase false
git config --global init.defaultBranch main

echo ""
echo "✅ Environment setup complete!"
echo "📝 Configuration ready for security setup"
echo ""
