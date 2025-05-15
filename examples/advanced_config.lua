-- Advanced Pears Configuration Example
-- ==================================
-- This configuration demonstrates advanced features of Pears.
-- It includes multiple environments, custom scripts, and system configuration.

return {
  -- Basic information
  name = "advanced_environment",
  description = "Advanced development environment with multiple languages",
  
  -- Environment variables
  env = {
    EDITOR = "nvim",
    VISUAL = "nvim",
    SHELL = "/bin/zsh",
    LANG = "en_US.UTF-8",
    LC_ALL = "en_US.UTF-8",
    
    -- Development environment variables
    NODE_ENV = "development",
    PYTHONUNBUFFERED = "1",
    
    -- Custom paths
    PATH = "$HOME/.local/bin:$PATH"
  },
  
  -- System packages (installed with Homebrew)
  system = {
    type = "brew",
    update = true,  -- Run 'brew update' before installing
    upgrade = true, -- Run 'brew upgrade' for all packages
    cleanup = true, -- Run 'brew cleanup' after installation
    
    packages = {
      -- Core Utilities
      { name = "coreutils", description = "GNU core utilities" },
      { name = "findutils" },
      { name = "gnu-sed" },
      { name = "gnu-tar" },
      { name = "gnu-which" },
      { name = "grep" },
      { name = "gnupg" },
      { name = "pinentry-mac" },
      
      -- Development
      { name = "git" },
      { name = "git-lfs" },
      { name = "github/gh/gh" },
      { name = "neovim" },
      { name = "tmux" },
      { name = "zsh" },
      { name = "zsh-completions" },
      { name = "zsh-syntax-highlighting" },
      { name = "zsh-autosuggestions" },
      
      -- Languages
      { name = "python@3.10" },
      { name = "node" },
      { name = "yarn" },
      { name = "go" },
      { name = "rustup-init" },
      
      -- Tools
      { name = "fzf" },
      { name = "ripgrep" },
      { name = "fd" },
      { name = "jq" },
      { name = "yq" },
      { name = "htop" },
      { name = "wget" },
      { name = "curl" },
      { name = "httpie" },
      { name = "bat" },
      { name = "exa" },
      { name = "tldr" },
      { name = "the_silver_searcher" },
      
      -- Containerization
      { name = "docker" },
      { name = "docker-compose" },
      { name = "docker-machine" },
      { name = "docker-machine-driver-xhyve" },
      { name = "kubernetes-cli" },
      { name = "kubectx" },
      { name = "kubens" },
      { name = "helm" },
      { name = "minikube" },
      { name = "skaffold" },
      
      -- Databases
      { name = "postgresql@14" },
      { name = "redis" },
      { name = "sqlite" },
      { name = "mongodb-community" },
      { name = "mysql" },
      
      -- Media
      { name = "ffmpeg" },
      { name = "imagemagick" },
      { name = "youtube-dl" }
    }
  },
  
  -- Python environment
  python = {
    type = "pip",
    version = "3.10",
    create_venv = true,
    venv_path = ".venv",
    requirements_file = "requirements.txt",
    
    packages = {
      -- Package management
      { name = "pip", version = "latest" },
      { name = "pipx" },
      { name = "poetry" },
      { name = "pipenv" },
      
      -- Development
      { name = "black" },
      { name = "isort" },
      { name = "flake8" },
      { name = "mypy" },
      { name = "pylint" },
      { name = "pytest" },
      { name = "pytest-cov" },
      { name = "ipython" },
      { name = "jupyter" },
      
      -- Data science
      { name = "numpy" },
      { name = "pandas" },
      { name = "matplotlib" },
      { name = "seaborn" },
      { name = "scikit-learn" },
      { name = "tensorflow" },
      { name = "torch" },
      
      -- Web development
      { name = "django" },
      { name = "flask" },
      { name = "fastapi" },
      { name = "uvicorn" },
      { name = "gunicorn" },
      { name = "requests" },
      { name = "httpx" },
      { name = "aiohttp" }
    }
  },
  
  -- Node.js environment
  node = {
    type = "npm",
    version = "18",  -- Using nvm to manage versions
    
    packages = {
      -- Package managers
      { name = "yarn" },
      { name = "pnpm" },
      
      -- Development tools
      { name = "typescript" },
      { name = "eslint" },
      { name = "prettier" },
      { name = "jest" },
      { name = "mocha" },
      { name = "nodemon" },
      { name = "ts-node" },
      
      -- Frontend frameworks
      { name = "react" },
      { name = "react-dom" },
      { name = "next" },
      { name = "vue" },
      { name = "@vue/cli" },
      { name = "svelte" },
      { name = "@sveltejs/kit" },
      
      -- Backend
      { name = "express" },
      { name = "koa" },
      { name = "fastify" },
      { name = "graphql" },
      { name = "apollo-server" }
    }
  },
  
  -- Rust environment
  rust = {
    type = "cargo",
    
    packages = {
      { name = "cargo-edit" },
      { name = "cargo-watch" },
      { name = "rustfmt" },
      { name = "clippy" },
      { name = "rust-analyzer" }
    }
  },
  
  -- Go environment
  go = {
    type = "go",
    
    packages = {
      { name = "golang.org/x/tools/gopls@latest" },
      { name = "github.com/go-delve/delve/cmd/dlv@latest" },
      { name = "golang.org/x/tools/cmd/goimports@latest" },
      { name = "github.com/segmentio/golines@latest" },
      { name = "honnef.co/go/tools/cmd/staticcheck@latest" }
    }
  },
  
  -- macOS specific settings (only applies on macOS)
  mac_settings = {
    system_preferences = {
      appearance = "auto",
      night_shift = true,
      dark_mode = true,
      auto_restart_on_power_failure = true,
      auto_restart_on_freeze = true
    },
    
    dock = {
      auto_hide = false,
      position = "bottom",
      autohide_delay = 0.5,
      autohide_time_modifier = 0.5,
      minimize_effect = "scale",
      show_recent_apps = false,
      show_hidden_apps = true,
      show_indicator_lights = true
    },
    
    keyboard = {
      key_repeat_delay = 10,
      key_repeat_rate = 2,
      fn_key_behavior = "app"
    },
    
    trackpad = {
      tracking_speed = 1.5,
      click_strength = 0.5,
      tap_to_click = true,
      scroll_direction_natural = false,
      zoom = true,
      rotate = true,
      swipe_between_pages = true,
      swipe_between_fullscreen_apps = true
    },
    
    finder = {
      show_hidden_files = true,
      show_all_extensions = true,
      show_path_bar = true,
      show_status_bar = true,
      show_tab_bar = true
    },
    
    security = {
      firewall_enabled = true,
      firewall_stealth_mode = true,
      automatic_updates = true,
      app_store_updates = true,
      system_data_files_security = true,
      system_integrity_protection = true
    },
    
    login_items = {
      "/Applications/Google Chrome.app",
      "/Applications/iTerm.app",
      "/Applications/Slack.app",
      "/Applications/Spotify.app"
    }
  },
  
  -- Hooks for different lifecycle events
  hooks = {
    pre_install = {
      { command = "echo 'Starting installation...'" },
      { command = "mkdir -p ~/Projects" },
      { command = "mkdir -p ~/.config" }
    },
    
    post_install = {
      { command = "echo 'Installation complete!'" },
      { command = "echo 'Configuring shell...'" },
      { command = "chsh -s /bin/zsh" },
      { command = "echo 'Setting up Git...'" },
      { command = "git config --global user.name 'Your Name'" },
      { command = "git config --global user.email 'your.email@example.com'" },
      { command = "git config --global core.editor 'nvim'" },
      { command = "git config --global pull.rebase true" },
      { command = "echo 'All done! 🎉'" }
    },
    
    on_update = {
      { command = "echo 'Updating packages...'" },
      { command = "brew upgrade" },
      { command = "npm update -g" },
      { command = "pip install --upgrade pip" }
    },
    
    on_clean = {
      { command = "echo 'Cleaning up...'" },
      { command = "brew cleanup" },
      { command = "npm cache clean --force" },
      { command = "pip cache purge" }
    }
  },
  
  -- Custom scripts to run
  scripts = {
    { name = "setup_ssh", command = "mkdir -p ~/.ssh && chmod 700 ~/.ssh" },
    { name = "setup_git_config", command = "git config --global pull.rebase true" },
    { name = "install_oh_my_zsh", command = 'sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"', interactive = true },
    { name = "install_oh_my_zsh_plugins", command = "git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" }
  },
  
  -- Debug settings
  debug = {
    verbose = false,
    dry_run = false,
    log_file = "pears.log",
    log_level = "info",  -- debug, info, warn, error
    color_output = true,
    show_timestamps = true
  }
}
