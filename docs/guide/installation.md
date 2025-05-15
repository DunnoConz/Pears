# Installation

There are several ways to install Pears on your system.

## Prerequisites

Before installing Pears, ensure you have the following:

- [Zig](https://ziglang.org/learn/getting-started/) (0.11.0 or later recommended)
- Lua 5.4 (required for configuration parsing)
- On macOS: Xcode Command Line Tools

## Installing from Source

1. Clone the repository:

```bash
git clone https://github.com/dunnoconz/pears.git
cd pears
```

2. Build Pears:

```bash
zig build -Doptimize=ReleaseSafe
```

3. Install the binary:

```bash
# On macOS/Linux
sudo cp zig-out/bin/pears /usr/local/bin/

# Or without sudo to a local bin directory
cp zig-out/bin/pears ~/.local/bin/
```

4. Verify the installation:

```bash
pears --version
```

## Using the Install Script

For convenience, you can use our install script:

```bash
curl -fsSL https://raw.githubusercontent.com/dunnoconz/pears/main/install.sh | bash
```

The script will:
- Check for prerequisites
- Clone the repository
- Build Pears
- Install it to /usr/local/bin (or ~/.local/bin if you don't have sudo access)

## Next Steps

After installing Pears, you can:

1. [Configure Pears](./configuration.md) by creating a `pears.lua` file
2. Learn the [basic commands](./basic-commands.md) to manage your environment
