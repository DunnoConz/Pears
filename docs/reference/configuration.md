# Configuration Reference

This page provides a complete reference for all available configuration options in Pears.

## Top-Level Configuration

| Option | Type | Description |
|--------|------|-------------|
| `name` | string | Name of the environment |
| `description` | string | Description of the environment |
| `system` | table | System package manager configuration |
| `python` | table | Python package manager configuration |
| `node` | table | Node.js package manager configuration |
| `rust` | table | Rust package manager configuration |
| `go` | table | Go package manager configuration |
| `mac_settings` | table | macOS system settings |
| `scripts` | table | Custom scripts to run |
| `hooks` | table | Pre and post-installation hooks |
| `custom_managers` | table | Custom package manager definitions |
| `logging` | table | Logging configuration |
| `parallel_install` | boolean | Enable parallel installation |
| `timeout` | number | Operation timeout in seconds |
| `retry` | table | Retry configuration |

## Package Manager Configuration

### Common Fields

All package manager configurations share these fields:

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Type of package manager (e.g., "brew", "pip") |
| `packages` | array | List of packages to install |

### Package Definition

Each package in the `packages` array can have the following fields:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name of the package |
| `version` | string | (Optional) Version constraint |
| `global` | boolean | (Optional) Install globally |
| `options` | array | (Optional) Additional installation options |
| `env` | table | (Optional) Environment variables for installation |
| `deps` | array | (Optional) Dependencies within the configuration |

## macOS Settings

The `mac_settings` table supports the following sections:

### System Preferences

| Field | Type | Description |
|-------|------|-------------|
| `appearance` | string | System appearance ("light", "dark", "auto") |
| `night_shift` | boolean | Enable/disable Night Shift |

### Dock

| Field | Type | Description |
|-------|------|-------------|
| `auto_hide` | boolean | Auto-hide the Dock |
| `position` | string | Dock position ("left", "bottom", "right") |
| `minimize_effect` | string | Window minimize effect |
| `recent_apps` | boolean | Show recent applications |
| `tilesize` | number | Size of Dock icons |

### Keyboard

| Field | Type | Description |
|-------|------|-------------|
| `key_repeat_delay` | number | Initial key repeat delay |
| `key_repeat_rate` | number | Key repeat rate |
| `use_fn_keys` | boolean | Use F1, F2, etc. as standard function keys |

### Security

| Field | Type | Description |
|-------|------|-------------|
| `firewall_enabled` | boolean | Enable/disable firewall |
| `require_password` | boolean | Require password after sleep or screen saver |
| `password_delay` | number | Delay before password is required (seconds) |

### Defaults Commands

| Field | Type | Description |
|-------|------|-------------|
| `domain` | string | Defaults domain |
| `key` | string | Preference key |
| `type` | string | Type of value ("string", "bool", "int", "float") |
| `value` | any | Value to set |

## Hooks

The `hooks` table can contain:

| Field | Type | Description |
|-------|------|-------------|
| `pre_install` | array | Commands to run before installation |
| `post_install` | array | Commands to run after installation |

## Custom Scripts

Each script in the `scripts` array can have:

| Field | Type | Description |
|-------|------|-------------|
| `command` | string/function | Command to run or Lua function |
| `description` | string | Description of the script |
| `condition` | function | Function that returns true/false to determine if script should run |

## Custom Package Managers

Each custom package manager can have:

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Name of the package manager |
| `install_cmd` | string | Command to install packages |
| `update_cmd` | string | Command to update packages |
| `uninstall_cmd` | string | Command to uninstall packages |
| `list_cmd` | string | Command to list installed packages |
| `packages` | array | List of packages to manage |

## Logging Configuration

| Field | Type | Description |
|-------|------|-------------|
| `level` | string | Log level ("debug", "info", "warn", "error") |
| `file` | string | Log file path |
| `format` | string | Log format ("simple", "detailed", "json") |

## Complete Example

```lua
return {
  name = "development_environment",
  description = "Full-stack development environment",

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
      { name = "flake8", version = ">=4.0.0" },
    }
  },

  -- Node.js packages
  node = {
    type = "npm",
    packages = {
      { name = "eslint", global = true },
      { name = "typescript", version = "^4.5.0" },
    }
  },

  -- macOS settings
  mac_settings = {
    system_preferences = {
      appearance = "dark",
    },
    dock = {
      auto_hide = true,
      position = "left",
    },
    keyboard = {
      key_repeat_delay = 15,
      key_repeat_rate = 2,
    },
    defaults = {
      { domain = "NSGlobalDomain", key = "AppleShowAllExtensions", type = "bool", value = true },
    }
  },

  -- Custom scripts
  scripts = {
    { command = "echo 'Installation complete!'" },
  },

  -- Hooks
  hooks = {
    pre_install = {
      { command = "echo 'Starting installation...'" },
    },
    post_install = {
      { command = "source ~/.zshrc" },
    },
  },

  -- Logging
  logging = {
    level = "info",
    file = "~/pears.log",
  },

  -- Performance
  parallel_install = true,
  timeout = 300,
}
```
