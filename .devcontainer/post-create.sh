#!/bin/bash
# Main orchestrator script that runs all setup scripts in order

set -euo pipefail

echo "🚀 Starting complete development environment setup..."
echo "===================================================="

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Load environment variables from .env
ENV_FILE="$SCRIPT_DIR/../.env"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Make all scripts executable
chmod +x "$SCRIPT_DIR"/*.sh

# Note: Step 1 (Environment setup) is handled by initializeCommand
# Starting with Step 2: Security setup (needs sudo)

if [ "$EUID" -eq 0 ]; then
    # Already running as root
    "$SCRIPT_DIR/01-security-setup.sh"
else
    # Need to use sudo
    sudo "$SCRIPT_DIR/01-security-setup.sh"
fi
if [ $? -ne 0 ]; then
    echo "❌ Security setup failed!"
    exit 1
fi


# Step 3: Infrastructure setup (no sudo needed)
echo ""
"$SCRIPT_DIR/02-infrastructure-setup.sh"
if [ $? -ne 0 ]; then
    echo "❌ Infrastructure setup failed!"
    exit 1
fi

# Step 4: Application setup (no sudo needed)
echo ""
"$SCRIPT_DIR/03-application-setup.sh"
if [ $? -ne 0 ]; then
    echo "❌ Application setup failed!"
    exit 1
fi

echo ""
echo "✅ All setup steps completed successfully!"
echo "===================================================="
echo ""
