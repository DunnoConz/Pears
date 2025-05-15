# Basic Commands

Pears provides a set of commands to manage your environment. This guide covers the most commonly used commands.

## Getting Help

```bash
pears --help
```

This displays a list of available commands and options.

## Installing Packages

To install all packages defined in your configuration file:

```bash
pears install
```

You can also specify a specific environment to install:

```bash
pears install my_environment
```

## Updating Packages

To update all packages to their latest versions:

```bash
pears update
```

## Listing Packages

To see what's installed:

```bash
pears list
```

This shows all packages managed by Pears.

## Removing Packages

To remove a specific package:

```bash
pears remove package_name
```

## Checking System Status

To diagnose issues with your setup:

```bash
pears doctor
```

This checks for common problems like missing dependencies or configuration issues.

## Dry Run Mode

To preview changes without actually making them:

```bash
pears install --dry-run
```

This is useful to see what would happen before making actual changes.

## Verbose Output

For more detailed logs:

```bash
pears install --verbose
```

## Environment Configuration

To specify a different configuration file:

```bash
pears install --config path/to/pears.lua
```

## Applying macOS Settings

To apply only macOS settings from your configuration:

```bash
pears apply mac-settings
```

## Running Hooks

To manually run hooks:

```bash
pears run-hooks pre_install
pears run-hooks post_install
```

## Example Workflows

### Setting Up a New Machine

```bash
# Install dependencies
pears install

# Apply macOS settings
pears apply mac-settings
```

### Updating an Existing Setup

```bash
# Update packages
pears update

# Check for issues
pears doctor
```

## Next Steps

Learn about [advanced usage](./advanced-usage.md) for more complex scenarios.
