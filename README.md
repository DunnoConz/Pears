# 🍐 Pears

Pears is a lightweight, fast, and reliable package manager and system configuration tool built with Zig and Lua. Inspired by Nix but designed to be more approachable, Pears provides a declarative way to manage your development environments and system settings across different platforms.

## ✨ Features

- **🚀 Blazing Fast**: Built with Zig for optimal performance and minimal overhead
- **📦 Multi-Package Manager Support**: Unified interface for:
  - macOS: Homebrew
  - Python: pip, pipx
  - JavaScript/TypeScript: npm, yarn, pnpm
  - Rust: Cargo
  - Go: go get
  - And more!
- **🖥️ System Configuration**:
  - macOS settings management (dock, keyboard, security, etc.)
  - Cross-platform environment setup
  - Custom scripts and hooks
- **🔒 Reliable & Safe**:
  - Dry-run mode to preview changes
  - Atomic operations where possible
  - Rollback support for failed installations
- **📝 Declarative Configuration**: Simple Lua-based configuration
- **⚡ Lightweight**: Minimal dependencies, fast startup time

## 🚀 Quick Start

1. **Install Pears**:
   ```bash
   # Clone the repository
   git clone https://github.com/dunnoconz/pears.git
   cd pears

   # Build and install
   zig build -Doptimize=ReleaseSafe
   sudo cp zig-out/bin/pears /usr/local/bin/
   ```

2. **Create a configuration file** (`pears.lua`):
   ```lua
   return {
     name = "my_environment",
     description = "My development environment",

     -- System packages (Homebrew)
     system = {
       type = "brew",
       packages = {
         { name = "git" },
         { name = "neovim" },
         { name = "tmux" },
       }
     },

     -- Python packages
     python = {
       type = "pip",
       packages = {
         { name = "black" },
         { name = "flake8" },
       }
     },
   }
   ```

3. **Install your environment**:
   ```bash
   pears install
   ```

## 📚 Documentation

For complete documentation, visit our [website](https://dunnoconz.github.io/pears/).

### Configuration Reference

Pears uses Lua for configuration. Here's a comprehensive reference of all available options:

```lua
return {
  -- Basic information
  name = "environment_name",
  description = "Description of this environment",

  -- System packages (Homebrew)
  system = {
    type = "brew",
    packages = {
      { name = "package_name" },
      { name = "package_with_version", version = "1.2.3" },
    }
  },

  -- Python packages
  python = {
    type = "pip",
    packages = {
      { name = "package_name" },
    }
  },

  -- Node.js packages
  node = {
    type = "npm",
    packages = {
      { name = "package_name" },
    }
  },

  -- macOS specific settings (only applies on macOS)
  mac_settings = {
    system_preferences = {
      appearance = "auto",  -- "light", "dark", or "auto"
      night_shift = true,
    },
    dock = {
      auto_hide = false,
      position = "bottom",  -- "left", "bottom", or "right"
    },
    keyboard = {
      key_repeat_delay = 15,  -- Default is 15 (225 ms)
      key_repeat_rate = 2,    -- Default is 2 (30 ms)
    },
    security = {
      firewall_enabled = true,
    },
  },

  -- Custom scripts to run after installation
  scripts = {
    { command = "echo 'Installation complete!'" },
  }
}
```

### Commands

- `pears install [environment]`: Install packages for the specified environment
- `pears update`: Update all packages to their latest versions
- `pears list`: List installed packages
- `pears remove [package]`: Remove a package
- `pears doctor`: Check for common issues
- `pears --help`: Show help message

### Advanced Usage

#### Environment Variables

- `PEARS_CONFIG`: Path to configuration file (default: `pears.lua`)
- `PEARS_VERBOSE`: Enable verbose output
- `PEARS_DRY_RUN`: Show what would be done without making changes

#### Hooks

You can define hooks to run at different stages of the installation process:

```lua
return {
  -- ... other config ...

  hooks = {
    pre_install = {
      { command = "echo 'Starting installation...'" },
    },
    post_install = {
      { command = "echo 'Installation complete!'" },
    },
  }
}
```

## 🤝 Contributing

Contributions are welcome! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by Nix, Homebrew, and other package managers
- Built with Zig for performance and reliability
- Lua for flexible configuration

## Mac Settings Management

Pears can manage various macOS system settings through the `mac_settings` section in your configuration file. Here's an example of what you can configure:

```lua
-- Mac-specific system settings
mac_settings = {
  -- System Preferences
  system_preferences = {
    appearance = "auto",  -- "light", "dark", or "auto"
    night_shift = true,
  },

  -- Dock settings
  dock = {
    auto_hide = false,
    position = "bottom",  -- "left", "bottom", or "right"
  },

  -- Window management
  window = {
    enable_snapping = true,
  },

  -- Keyboard settings
  keyboard = {
    key_repeat_delay = 15,  -- Default is 15 (225 ms)
    key_repeat_rate = 2,    -- Default is 2 (30 ms)
  },

  -- Security settings
  security = {
    firewall_enabled = true,
  },

  -- Network settings
  network = {
    wifi_power = true,
  },

  -- Login items (apps that launch at login)
  login_items = {
    "/Applications/Google Chrome.app",
    "/Applications/Spotify.app",
  },

  -- Development environment
  development = {
    install_xcode_cli = true,  -- Install Xcode Command Line Tools if missing
    install_homebrew = true,    -- Install Homebrew if missing
  },

  -- Backup settings
  backup = {
    dotfiles_dir = "~/.pears/dotfiles_backup",  -- Directory to backup dotfiles to
  },
}
```

## Prerequisites

- [Zig](https://ziglang.org/learn/getting-started/) (0.11.0 or later recommended)
- A supported package manager (Homebrew, Cargo, npm, pip, etc.)
- Lua (for configuration parsing)
- On macOS: Xcode Command Line Tools (for some features)

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/dunnoconz/pears.git
   cd pears
   ```

2. Build the project:
   ```sh
   zig build
   ```

3. Install the binary (optional):
   ```sh
   # For system-wide installation (requires sudo)
   sudo cp zig-out/bin/pears /usr/local/bin/

   # Or add to your PATH
   export PATH="$(pwd)/zig-out/bin:$PATH"
   ```

## Usage

### Basic Commands

```sh
# Show help
pears --help

# Install packages for a specific environment
pears install [environment]

# Install with verbose output
pears install -v

# Dry run (show what would be installed)
pears install -n

# Use a custom config file
pears install --config my_config.lua
```

### Configuration Examples

#### Basic Configuration

```lua
-- pears.lua
return {
    -- System packages (installed via Homebrew)
    system = {
        type = "brew",
        packages = {
            { name = "ripgrep" },
            { name = "fd" },
            { name = "fzf" },
            { name = "bat" },
            { name = "eza" },
            { name = "zoxide" },
        }
    },

    -- Node.js packages
    node = {
        type = "npm",
        packages = {
            { name = "typescript" },
            { name = "prettier" },
            { name = "eslint" },
            { name = "@biomejs/biome" },
        }
    },

    -- Python packages
    python = {
        type = "pip",
        packages = {
            { name = "black" },
            { name = "isort" },
            { name = "pylint" },
        }
    },

    -- Rust tools
    rust = {
        type = "cargo",
        packages = {
            { name = "cargo-edit" },
            { name = "cargo-watch" },
            { name = "cargo-expand" },
        }
    },

    -- Custom scripts
    scripts = {
        {
            name = "jetzig-cli",
            type = "script",
            script = "curl -fsSL https://install.jetzig.dev | bash"
        },
        {
            name = "shell-config",
            type = "script",
            script = "echo 'export PATH=\"$HOME/.jetzig/bin:$PATH\"' >> ~/.zshrc"
        }
    }
}
```

## Development

### Building and Testing

```sh
# Build in debug mode (default)
zig build

# Build in release mode
zig build -Doptimize=ReleaseSafe

# Run tests
zig build test

# Run specific test
zig build test-pears

# Run all tests
zig build test-all
```

### Project Structure

- `src/` - Source code
  - `main.zig` - CLI entry point
  - `deps.zig` - Package management logic
- `pears.lua` - Default configuration file
- `test_pears.zig` - Test suite
- `build.zig` - Build configuration

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

    system = {
        hostname = "my-macbook",
        shell = "/bin/zsh"  -- Default shell to use
    },

    dependencies = {
        -- System utilities via Homebrew
        { name = "git", type = "brew" },
        { name = "curl", type = "brew" },
        { name = "jq", type = "brew" },

        -- Development tools
        { name = "neovim", type = "brew" },
        { name = "tmux", type = "brew" },

        -- Node.js ecosystem
        { name = "node", type = "brew", version = "18" },
        { name = "yarn", type = "npm", global = true },

        -- Python environment
        { name = "python@3.11", type = "brew" },
        { name = "black", type = "pip" },

        -- Database systems
        { name = "postgresql@14", type = "brew" },
        { name = "redis", type = "brew" }
    },

    environment = {
        EDITOR = "nvim",
        LANG = "en_US.UTF-8",
        LC_ALL = "en_US.UTF-8"
    },

    post_install = function()
        -- Any post-installation scripts
        print("Environment setup complete!")
    end
}
```

### Applying Your Configuration

```sh
# Apply the configuration
./zig-out/bin/pears apply config.lua

# Check the status of your environment
./zig-out/bin/pears status

# Update all packages
./zig-out/bin/pears update

# Switch to a different configuration
./zig-out/bin/pears switch other-config.lua
```

### Advanced: Custom Package Management

You can define custom package sources and build steps:

```lua
return {
    name = "custom_packages",

    packages = {
        {
            name = "my_custom_tool",
            type = "custom",
            source = "https://github.com/user/my-custom-tool",
            build = [[
                make
                make install PREFIX=$out
            ]],
            dependencies = { "cmake", "gcc" }
        }
    }
}
```

## Development

### Building

To build Pears, you need Zig installed. Then run:

```sh
zig build
```

### Running Tests

```sh
zig build test
```

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

[Add your license here]

## Acknowledgments

- Inspired by Nix and NixOS
- Built with Zig and Luau

## Running

To run Pears after building:

```sh
zig build run
```

## Testing

### Unit Tests

Run the test suite with:

```sh
zig build test
```

### Mac Settings Testing

To test the Mac settings management functionality, use the provided test script:

```sh
# Make the script executable if needed
chmod +x test_mac_settings.sh

# Run the test script
./test_mac_settings.sh
```

This script will:
1. Create a test configuration file
2. Apply the settings using Pears
3. Verify that the settings were applied correctly
4. Clean up temporary files

Note: Some settings may require a restart of the Dock or system to take effect.

### Test Script Information

```sh
{{ ... }}
zig build run
