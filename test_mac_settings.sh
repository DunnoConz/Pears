#!/bin/bash

# Test script to verify Mac settings management

echo "Testing Mac settings management..."

# Check if pears is in PATH
if ! command -v pears &> /dev/null; then
    echo "Error: pears command not found. Please build and install Pears first."
    exit 1
fi

# Create a test config file
cat > test_config.lua << 'EOL'
return {
    mac_settings = {
        system_preferences = {
            appearance = "auto",
            night_shift = true
        },
        dock = {
            auto_hide = false,
            position = "bottom"
        },
        window = {
            enable_snapping = true
        },
        keyboard = {
            key_repeat_delay = 15,
            key_repeat_rate = 2
        },
        security = {
            firewall_enabled = true
        },
        network = {
            wifi_power = true
        },
        login_items = {
            "/System/Applications/Calculator.app"
        },
        development = {
            install_xcode_cli = true,
            install_homebrew = true
        },
        backup = {
            dotfiles_dir = "~/.pears/test_dotfiles_backup"
        }
    }
}
EOL

# Run pears with the test config
echo "Applying test configuration..."
./zig-out/bin/pears -v apply test_config.lua

# Verify some settings
echo "\nVerifying settings..."

# Check dock settings
dock_autohide=$(defaults read com.apple.dock autohide)
dock_position=$(defaults read com.apple.dock orientation)
key_repeat_delay=$(defaults read -g InitialKeyRepeat)
key_repeat_rate=$(defaults read -g KeyRepeat)

# Verify dock settings
if [ "$dock_autohide" = "0" ] && [ "$dock_position" = "bottom" ]; then
    echo "✅ Dock settings applied successfully"
else
    echo "❌ Dock settings not applied as expected"
fi

# Verify keyboard settings
if [ "$key_repeat_delay" = "225" ] && [ "$key_repeat_rate" = "2" ]; then
    echo "✅ Keyboard settings applied successfully"
else
    echo "❌ Keyboard settings not applied as expected"
fi

# Clean up
rm test_config.lua
echo "\nTest complete. Don't forget to restart the Dock for changes to take effect:"
echo "killall Dock"
