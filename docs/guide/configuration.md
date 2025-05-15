# Configuration Guide

Pears uses Lua for configuration, making it flexible and powerful. This guide explains how to create and customize your configuration file.

## Basic Configuration

Create a file named `pears.lua` in your project or home directory:

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

## Configuration Sections

### Basic Information

```lua
name = "environment_name",
description = "Description of this environment",
```

### Package Managers

Pears supports multiple package managers:

#### Homebrew (macOS)

```lua
system = {
  type = "brew",
  packages = {
    { name = "package_name" },
    { name = "package_with_version", version = "1.2.3" },
  }
}
```

#### Python (pip)

```lua
python = {
  type = "pip",
  packages = {
    { name = "package_name" },
    { name = "package_with_version", version = "1.2.3" },
  }
}
```

#### Node.js (npm, yarn, pnpm)

```lua
node = {
  type = "npm", -- or "yarn" or "pnpm"
  packages = {
    { name = "package_name" },
    { name = "global_package", global = true },
  }
}
```

#### Rust (Cargo)

```lua
rust = {
  type = "cargo",
  packages = {
    { name = "package_name" },
  }
}
```

### macOS System Settings

```lua
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
}
```

### Custom Scripts

```lua
scripts = {
  { command = "echo 'Installation complete!'" },
  {
    command = "mkdir -p ~/workspace",
    description = "Create workspace directory",
  },
}
```

### Hooks

```lua
hooks = {
  pre_install = {
    { command = "echo 'Starting installation...'" },
  },
  post_install = {
    { command = "echo 'Installation complete!'" },
  },
}
```

## Using Environment Variables

You can access environment variables in your configuration:

```lua
return {
  name = "custom_env",

  -- Use environment variables
  scripts = {
    { command = "echo $HOME" },
    { command = "export MY_VAR=value" },
  }
}
```

## Using Multiple Configuration Files

You can split your configuration across multiple files:

```lua
-- Base configuration (base.lua)
local base = {
  name = "base",
  system = {
    type = "brew",
    packages = {
      { name = "git" },
    }
  }
}

-- Include in main configuration (pears.lua)
local base = require("base")
return {
  name = "extended",
  -- Merge base configuration
  system = base.system,
  -- Add more packages
  python = {
    type = "pip",
    packages = {
      { name = "black" },
    }
  }
}
```

## Next Steps

- Learn about [basic commands](./basic-commands.md) to manage your environment
- Explore [advanced usage](./advanced-usage.md) options
