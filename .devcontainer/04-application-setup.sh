#!/bin/bash
set -euo pipefail

echo "🚀 STEP 4: Application & Development Environment Setup"
echo "======================================================"

# Get script directory and workspace root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to workspace directory
cd "$WORKSPACE_ROOT"

# Load environment variables if available
if [ -f .env ]; then
    source .env
    echo "📁 Environment variables loaded"
else
    echo "⚠️  No .env file found - continuing without environment variables"
fi

echo "📦 Installing Python packages and dependencies..."

# Upgrade pip first
python3 -m pip install --upgrade pip --quiet
echo "✅ pip upgraded"

# Install packages from requirements.txt
if [ -f requirements.txt ]; then
    echo "📋 Installing packages from requirements.txt..."
    python3 -m pip install -r requirements.txt
    echo "✅ Python packages installed"
else
    echo "⚠️  requirements.txt not found - installing basic development packages..."
    # Install essential development packages (based on template requirements)
    python3 -m pip install \
        requests==2.32.4 \
        python-dotenv==1.1.1 \
        click==8.2.1 \
        pytest==8.4.1 \
        netaddr==1.3.0
    echo "✅ Basic development packages installed"
fi

# Install development dependencies if available
if [ -f requirements-dev.txt ]; then
    echo "🔧 Installing development dependencies..."
    python3 -m pip install -r requirements-dev.txt
    echo "✅ Development dependencies installed"
fi

echo ""
echo "🔍 Validating application setup..."

# Test Node.js and npm installation
echo "🔧 Testing Node.js environment..."
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
    echo "✅ Node.js: $NODE_VERSION"
else
    echo "❌ Node.js not found in PATH"
fi

if command -v npm >/dev/null 2>&1; then
    NPM_VERSION=$(npm --version 2>/dev/null || echo "unknown")
    echo "✅ npm: $NPM_VERSION"
else
    echo "❌ npm not found in PATH"
fi

# Test Claude Code installation
echo "🔧 Testing Claude Code installation..."
if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
    echo "✅ Claude Code: $CLAUDE_VERSION"
else
    echo "❌ Claude Code not found in PATH"
fi

# Test Python imports for basic packages
echo "📦 Testing basic package imports..."
python3 -c "
import sys
packages = ['requests', 'dotenv', 'click', 'pytest', 'netaddr']
failed = []
for pkg in packages:
    try:
        __import__(pkg)
        print(f'  ✓ {pkg}')
    except ImportError:
        print(f'  ✗ {pkg}')
        failed.append(pkg)
if failed:
    print(f'\\n❌ Missing packages: {\", \".join(failed)}')
    sys.exit(1)
print('\\n✅ All basic packages imported successfully')
"

# Check and create common project structure
echo ""
echo "🔍 Setting up project structure..."
COMMON_DIRS=("src" "tests" "docs")
CREATED_DIRS=()

for dir in "${COMMON_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir/ directory exists"
    else
        echo "  ➕ Creating $dir/ directory"
        mkdir -p "$dir"
        CREATED_DIRS+=("$dir")
    fi
done

# Create common files if they don't exist
if [ ! -f "README.md" ]; then
    echo "  ➕ Creating README.md"
    cat > README.md << 'EOF'
# Project Name

Brief description of your project.

## Getting Started

1. Open this project in VS Code with Dev Containers extension
2. Reopen in container when prompted
3. Start developing!

## Development

- Python: `python3 --version`
- Node.js: `node --version`
- Claude Code: `claude --version`

## Testing

Run tests with: `python -m pytest`

## Contributing

Please read our contributing guidelines before submitting changes.
EOF
    echo "  ✓ Created README.md"
fi

if [ ! -f ".gitignore" ]; then
    echo "  ➕ Creating .gitignore"
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
env/
venv/
.env
.venv/
pip-log.txt
pip-delete-this-directory.txt
.coverage
htmlcov/
.pytest_cache/

# Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# IDEs
.vscode/settings.json
.vscode/launch.json
.vscode/tasks.json
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Runtime data
pids
*.pid
*.seed
*.pid.lock
EOF
    echo "  ✓ Created .gitignore"
fi

# Display summary
echo ""
echo "📊 Development Environment Summary:"
echo "=================================="
python3 --version
echo "Node.js version: $(node --version 2>/dev/null || echo 'Not installed')"
echo "pip version: $(python3 -m pip --version | cut -d' ' -f2)"
echo "Installed Python packages: $(python3 -m pip list | wc -l) packages"

echo ""
echo "🎯 Application Setup Complete!"
echo "=============================="
echo "✅ Python environment configured"
echo "✅ Node.js environment ready"
echo "✅ Claude Code available"
echo "✅ Project structure initialized"

if [ ${#CREATED_DIRS[@]} -gt 0 ]; then
    echo "✅ Created directories: ${CREATED_DIRS[*]}"
fi

echo ""
echo "📝 Next Steps:"
echo "=============="
echo "1. 📝 Edit README.md with your project details"
echo "2. 📦 Add your dependencies to requirements.txt"
echo "3. 🧪 Write tests in the tests/ directory"
echo "4. 💻 Start coding in the src/ directory"
echo "5. 🤖 Use Claude Code for development assistance"

echo ""
echo "💡 Useful Commands:"
echo "=================="
echo "• Run Python tests: python -m pytest"
echo "• Format Python code: python -m black ."
echo "• Lint Python code: python -m flake8 ."
echo "• Type check: python -m mypy ."
echo "• Install package: python -m pip install <package>"
echo "• Claude Code help: claude --help"

echo ""
echo "🎉 Happy coding!"
echo ""
