#!/bin/bash

# Initialize .env file if it doesn't exist
if [ ! -f .env ] && [ -f .env.example ]; then
    cp .env.example .env
    echo "✅ Created .env file from .env.example"
    
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
fi

# Install Python packages from requirements.txt
sudo python3 -m pip install --upgrade pip
if [ -f requirements.txt ]; then
    sudo python3 -m pip install -r requirements.txt
    echo "✅ Python packages installed from requirements.txt"
else
    # Fallback to manual installation
    sudo python3 -m pip install \
        netaddr
    echo "✅ Python packages installed manually"
fi

# Load environment variables if .env exists
if [ -f .env ]; then
    source .env
    echo "✅ Environment variables loaded from .env"
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

echo "🚀 Development environment setup complete!"
echo "📝 Next steps:"
if [ -f .env ]; then
    echo "   - Review .env file for any additional configuration needed"
    echo "   - Adjust network security settings if needed for your environment"
else
    echo "   - Copy .env.example to .env and update with your information"
fi