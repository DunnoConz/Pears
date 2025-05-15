#!/bin/bash
# Pears installation script
# This script installs Pears and its dependencies

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status messages
status() {
  echo -e "${GREEN}[*]${NC} $1"
}

error() {
  echo -e "${RED}[!] Error: $1${NC}" >&2
  exit 1
}

warning() {
  echo -e "${YELLOW}[!] Warning: $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
  error "This script should not be run as root. Please run as a normal user."
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for required commands
for cmd in git curl unzip; do
  if ! command -v $cmd &> /dev/null; then
    error "$cmd is required but not installed. Please install it first."
  fi
done

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
  status "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH if not already there
  if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ "$SHELL" == "/bin/bash" ]]; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  status "Homebrew is already installed. Updating..."
  brew update
fi

# Install required dependencies
status "Installing dependencies..."
brew install lua luarocks zig

# Install Lua modules via LuaRocks
status "Installing Lua modules..."
luarocks install --lua-version=5.1 lpeg
luarocks install --lua-version=5.1 luafilesystem
luarocks install --lua-version=5.1 luasocket
luarocks install --lua-version=5.1 lua-cjson
luarocks install --lua-version=5.1 lua-yaml

# Build Pears
status "Building Pears..."
cd "$SCRIPT_DIR"
zig build -Doptimize=ReleaseSafe

# Create symlink to /usr/local/bin if it exists and is writable
if [[ -w "/usr/local/bin" ]]; then
  status "Creating symlink in /usr/local/bin..."
  sudo ln -sf "$SCRIPT_DIR/zig-out/bin/pears" /usr/local/bin/pears
else
  warning "Could not create symlink in /usr/local/bin (permission denied)."
  warning "You may want to add $SCRIPT_DIR/zig-out/bin to your PATH."
  
  if [[ "$SHELL" == "/bin/zsh" ]]; then
    echo "export PATH=\"$SCRIPT_DIR/zig-out/bin:\$PATH\"" >> ~/.zshrc
    source ~/.zshrc
  elif [[ "$SHELL" == "/bin/bash" ]]; then
    echo "export PATH=\"$SCRIPT_DIR/zig-out/bin:\$PATH\"" >> ~/.bash_profile
    source ~/.bash_profile
  fi
  
  status "Added Pears to your PATH. Please restart your shell or run 'source ~/.${SHELL##*/}rc'"
fi

# Verify installation
if command -v pears &> /dev/null; then
  status "Pears has been successfully installed!"
  echo -e "\nTo get started, run:\n"
  echo -e "  ${YELLOW}pears --help${NC}\n"
  echo -e "You may want to create a configuration file (pears.lua) in your project directory."
  echo -e "See the examples in the 'examples' directory for reference.\n"
else
  warning "Pears installation completed but the 'pears' command is not in your PATH."
  echo -e "You can run Pears directly with:\n"
  echo -e "  ${YELLOW}$SCRIPT_DIR/zig-out/bin/pears --help${NC}\n"
fi

exit 0
