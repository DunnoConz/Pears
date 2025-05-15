-- Pears Environment Configuration
-- This configuration defines a full-stack developer environment with various tools

-- Import Lute modules (these will be provided by the Pears runtime)
local process = require("lute.process")
local fs = require("lute.fs")
local system = require("lute.system")

-- Define the development environment
return {
    name = "fullstack_dev",
    description = "Full-stack development environment for macOS with multiple language support",
    dependencies = {
        -- System utilities via Homebrew
        {
            name = "git",
            type = "brew",
            version = "latest"
        },
        {
            name = "curl",
            type = "brew",
            version = "latest"
        },
        {
            name = "jq",
            type = "brew",
            version = "latest"
        },
        {
            name = "ripgrep",
            type = "brew",
            version = "latest"
        },

        -- Node.js ecosystem
        {
            name = "node",
            type = "brew",
            version = "18"
        },
        {
            name = "typescript",
            type = "npm",
            version = "latest"
        },
        {
            name = "vercel",
            type = "npm",
            version = "latest"
        },

        -- Python ecosystem
        {
            name = "python@3.10",
            type = "brew",
            version = "latest"
        },
        {
            name = "pipx",
            type = "brew",
            version = "latest"
        },
        {
            name = "jupyter",
            type = "pip",
            version = "latest"
        },

        -- Rust ecosystem
        {
            name = "rustup-init",
            type = "brew",
            version = "latest"
        },
        {
            name = "cargo-watch",
            type = "cargo",
            version = "latest"
        },

        -- Go ecosystem
        {
            name = "go",
            type = "brew",
            version = "latest"
        },
        {
            name = "golang.org/x/tools/gopls@latest",
            type = "go",
            version = "latest"
        },

        -- Applications
        {
            name = "visual-studio-code",
            type = "brew",
            version = "latest"
        },
        {
            name = "docker",
            type = "brew",
            version = "latest"
        },

        -- Custom scripts
        {
            name = "dotfiles",
            type = "custom",
            url = "curl -s https://raw.githubusercontent.com/username/dotfiles/main/install.sh | bash"
        }
    },

    -- Custom setup script that runs after dependencies are installed
    setup = function()
        -- Initialize Rust toolchain
        print("Initializing Rust toolchain...")
        local result = process.run({"rustup", "default", "stable"})

        -- Install VS Code extensions
        print("Installing VS Code extensions...")
        process.run({"code", "--install-extension", "golang.go"})
        process.run({"code", "--install-extension", "rust-lang.rust-analyzer"})
        process.run({"code", "--install-extension", "ms-python.python"})
        process.run({"code", "--install-extension", "dbaeumer.vscode-eslint"})

        -- Create project directories
        print("Creating project directories...")
        local home = process.env["HOME"]
        process.run({"mkdir", "-p", home.."/Developer/Projects"})

        print("Full-stack development environment setup complete!")
        print("Your development environment is ready at ~/Developer/Projects")
    end
}
