-- Basic Pears Configuration Example
-- ===============================
-- This is a minimal configuration file to get started with Pears.
-- Save this as `pears.lua` in your project directory or home directory.

return {
  -- Basic information
  name = "my_environment",
  description = "A basic development environment",
  
  -- Environment variables
  env = {
    EDITOR = "nano",  -- Change to your preferred editor
    SHELL = "/bin/zsh"
  },
  
  -- System packages (installed via Homebrew on macOS)
  system = {
    type = "brew",
    update = true,
    upgrade = true,
    cleanup = true,
    
    packages = {
      -- Core utilities
      { name = "git" },
      { name = "curl" },
      { name = "wget" },
      { name = "htop" },
      
      -- Development tools
      { name = "neovim" },
      { name = "tmux" },
      { name = "fzf" }  -- Fuzzy finder
    }
  },
  
  -- Python packages
  python = {
    type = "pip",
    version = "3.10",
    create_venv = true,
    venv_path = ".venv",
    
    packages = {
      { name = "pip", version = "latest" },
      { name = "black" },  -- Python formatter
      { name = "flake8" }, -- Linter
      { name = "pytest" }  -- Testing framework
    }
  },
  
  -- Node.js packages (optional)
  node = {
    type = "npm",
    packages = {
      { name = "typescript" },
      { name = "prettier" },
      { name = "eslint" }
    }
  },
  
  -- Hooks (optional)
  hooks = {
    post_install = {
      { command = "echo 'Installation complete!'" },
      { command = "mkdir -p ~/Projects" }
    }
  },
  
  -- Debug settings (optional)
  debug = {
    verbose = false,
    dry_run = false,
    log_file = "pears.log"
  }
}
