#!/bin/bash
set -e

echo "🚀 Starting transition from Nix to Pears..."

# Create backup directory
BACKUP_DIR=~/nix_backup_$(date +%Y%m%d_%H%M%S)
mkdir -p "$BACKUP_DIR"

echo "📦 Backing up Nix configuration..."

# Backup Nix configuration if it exists
if [ -d /nix ]; then
    echo "  - Backing up /nix directory..."
    sudo cp -r /nix "$BACKUP_DIR/nix_backup"
fi

if [ -f /etc/nix/nix.conf ]; then
    echo "  - Backing up Nix configuration..."
    sudo cp -r /etc/nix "$BACKUP_DIR/etc_nix_backup"
fi

# Clean up shell configuration files
echo "🧹 Cleaning up shell configuration..."

# Remove Nix from shell configuration
for file in ~/.zshrc ~/.bashrc ~/.bash_profile ~/.profile; do
    if [ -f "$file" ]; then
        echo "  - Cleaning up $file..."
        cp "$file" "${file}.bak"
        grep -v '/nix' "${file}.bak" > "$file"
    fi
done

# Remove Nix if it exists
if [ -d /nix ]; then
    echo "🗑️  Removing Nix installation..."
    read -p "This will remove Nix and all its packages. Continue? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo rm -rf /nix
        sudo rm -rf /etc/nix
        echo "✅ Nix has been removed."
    else
        echo "⚠️  Nix removal skipped. You may need to remove it manually."
    fi
else
    echo "ℹ️  Nix not found, skipping removal."
fi

# Install Pears if not already installed
if [ ! -f "/usr/local/bin/pears" ]; then
    echo "📥 Installing Pears..."
    cd /tmp
    git clone https://github.com/yourusername/pears.git
    cd pears
    zig build -Doptimize=ReleaseSafe
    sudo cp zig-out/bin/pears /usr/local/bin/
    echo "✅ Pears installed successfully!"
else
    echo "✅ Pears is already installed."
fi

# Initialize Pears with the new configuration
echo "⚙️  Initializing Pears with the new configuration..."
cp pears_config.lua ~/.pears/config.lua

# Install all packages
echo "📦 Installing packages with Pears..."
pears install

echo ""
echo "✨ Transition from Nix to Pears is complete!"
echo "Please restart your shell or run 'source ~/.zshrc' to apply all changes."
echo "A backup of your Nix configuration has been saved to: $BACKUP_DIR"
echo ""
echo "To verify the installation, run:"
echo "  pears list"
echo "  pears status"
echo ""
