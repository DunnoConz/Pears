# Commands Reference

This page lists all available commands and options in Pears.

## Main Commands

| Command | Description | Example |
|---------|-------------|---------|
| `install` | Install packages defined in configuration | `pears install` |
| `update` | Update packages to latest versions | `pears update` |
| `list` | List installed packages | `pears list` |
| `remove` | Remove a package | `pears remove package_name` |
| `doctor` | Check for common issues | `pears doctor` |
| `apply` | Apply specific configuration sections | `pears apply mac-settings` |
| `run-hooks` | Run specific hooks | `pears run-hooks pre_install` |

## Global Options

These options can be used with any command:

| Option | Description | Example |
|--------|-------------|---------|
| `--help`, `-h` | Show help information | `pears --help` |
| `--version`, `-v` | Show version information | `pears --version` |
| `--config`, `-c` | Specify configuration file | `pears --config ~/my_pears.lua` |
| `--verbose` | Enable verbose output | `pears --verbose install` |
| `--quiet`, `-q` | Suppress non-essential output | `pears --quiet install` |
| `--dry-run` | Preview changes without making them | `pears --dry-run install` |
| `--no-color` | Disable colored output | `pears --no-color install` |

## Command Details

### `install`

Install packages defined in the configuration file.

**Usage:**
```bash
pears install [environment] [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--only` | Install only specific types of packages |
| `--exclude` | Exclude specific types of packages |
| `--force` | Force reinstallation of packages |

**Examples:**
```bash
# Install all packages
pears install

# Install a specific environment
pears install my_environment

# Install only Python packages
pears install --only python

# Install everything except Node.js packages
pears install --exclude node
```

### `update`

Update installed packages to their latest versions.

**Usage:**
```bash
pears update [package] [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--only` | Update only specific types of packages |
| `--exclude` | Exclude specific types of packages |

**Examples:**
```bash
# Update all packages
pears update

# Update only a specific package
pears update git

# Update only Python packages
pears update --only python
```

### `list`

List installed packages.

**Usage:**
```bash
pears list [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--format` | Output format (text, json) |
| `--only` | List only specific types of packages |

**Examples:**
```bash
# List all packages
pears list

# List packages in JSON format
pears list --format json

# List only Homebrew packages
pears list --only brew
```

### `remove`

Remove an installed package.

**Usage:**
```bash
pears remove <package> [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--force` | Force removal without confirmation |

**Examples:**
```bash
# Remove a package
pears remove git

# Force remove without confirmation
pears remove git --force
```

### `doctor`

Check for common issues with the configuration and environment.

**Usage:**
```bash
pears doctor [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--fix` | Attempt to fix issues automatically |

**Examples:**
```bash
# Check for issues
pears doctor

# Check and try to fix issues
pears doctor --fix
```

### `apply`

Apply specific sections of the configuration.

**Usage:**
```bash
pears apply <section> [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--force` | Force apply even if already applied |

**Examples:**
```bash
# Apply macOS settings
pears apply mac-settings

# Apply Python packages
pears apply python
```

### `run-hooks`

Run specific hooks defined in the configuration.

**Usage:**
```bash
pears run-hooks <hook_type> [options]
```

**Options:**
| Option | Description |
|--------|-------------|
| `--force` | Force run hooks even if already run |

**Examples:**
```bash
# Run pre-installation hooks
pears run-hooks pre_install

# Run post-installation hooks
pears run-hooks post_install
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PEARS_CONFIG` | Path to configuration file | `./pears.lua` |
| `PEARS_VERBOSE` | Enable verbose output | `0` |
| `PEARS_DRY_RUN` | Enable dry run mode | `0` |
| `PEARS_NO_COLOR` | Disable colored output | `0` |
| `PEARS_LOG_LEVEL` | Set logging level | `info` |
| `PEARS_LOG_FILE` | Path to log file | None |

**Examples:**
```bash
# Use a specific configuration file
PEARS_CONFIG=~/custom_pears.lua pears install

# Enable verbose output
PEARS_VERBOSE=1 pears install

# Enable dry run mode
PEARS_DRY_RUN=1 pears install
```
