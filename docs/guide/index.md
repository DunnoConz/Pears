# Introduction to Pears

Pears is a lightweight, fast, and reliable package manager and system configuration tool built with Zig and Lua. Inspired by Nix but designed to be more approachable, Pears provides a declarative way to manage your development environments and system settings across different platforms.

## Why Pears?

Traditional package managers often have limitations:

- They work only for specific ecosystems (npm for Node.js, pip for Python)
- They don't handle system configuration
- They can be slow and resource-intensive

Pears addresses these issues by:

- Providing a unified interface for multiple package managers
- Supporting system configuration in addition to package management
- Being built with performance in mind using Zig
- Using a simple and expressive configuration format with Lua

## Key Features

- **Multi-Package Manager Support**: Manage packages from Homebrew, pip, npm, Cargo, and more
- **System Configuration**: Manage macOS settings and cross-platform environment setup
- **Declarative Configuration**: Simple Lua-based configuration
- **Performance**: Built with Zig for speed and efficiency
- **Safety**: Dry-run mode, atomic operations, and rollback support

## Next Steps

- [Installation](./installation.md): Install Pears on your system
- [Configuration](./configuration.md): Learn how to configure Pears
- [Basic Commands](./basic-commands.md): Start using Pears
