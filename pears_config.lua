-- Pears Configuration
-- ===================
-- This is a declarative configuration file for Pears, a lightweight package manager
-- and system configuration tool. It uses Lua syntax for configuration.
--
-- For full documentation, see: https://github.com/yourusername/pears

return {
  -- Basic Information
  -- ----------------
  name = "my_environment",
  description = "My development environment configuration",
  
  -- Environment Variables
  -- ------------------
  env = {
    EDITOR = "nvim",
    SHELL = "/bin/zsh"
    -- Add custom environment variables here
  },
  -- macOS System Settings
  -- -------------------
  -- These settings only apply on macOS systems
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

    -- Login items
    login_items = {
      -- Add paths to apps that should launch at login
      -- Example: "/Applications/Google Chrome.app"
    },

    -- Development Tools
    development = {
      install_xcode_cli = true,  -- Install Xcode Command Line Tools if not present
      install_homebrew = true,   -- Install Homebrew if not present
      
      -- Configure default applications
      default_apps = {
        terminal = "/Applications/Kitty.app",
        editor = "/Applications/Neovim.app",
        browser = "/Applications/Google Chrome.app"
      },
    },

    -- Backup settings
    backup = {
      dotfiles_dir = "~/.pears/dotfiles_backup",
    },
  },

  
  -- Package management
  -- Git-based packages
  git_packages = {
    type = "git",
    packages = {
      -- Fast file finder (GitHub, main branch)
      {
        name = "fd",
        source = "github",
        owner = "sharkdp",
        repo = "fd",
        ref = {
          type = "branch",
          name = "master"
        }
      },
      
      -- Modern ls command (GitHub, latest release)
      {
        name = "eza",
        source = "github",
        owner = "eza-community",
        repo = "eza",
        ref = {
          type = "tag",
          name = "v0.17.0"  -- Latest release as of now
        }
      },
      
      -- GitLab example (GNOME's GitLab instance)
      {
        name = "gtk",
        source = "gitlab",
        owner = "gnome",
        repo = "gtk",
        ref = {
          type = "branch",
          name = "main"
        },
        subdir = "gtk"  -- Install from the gtk subdirectory
      },
      
      -- Another GitLab example (GitLab's own project)
      {
        name = "gitlab-runner",
        source = "gitlab",
        owner = "gitlab-org",
        repo = "gitlab-runner",
        ref = {
          type = "tag",
          name = "v16.10.0"  -- Latest stable release
        }
      },
      
      -- Example with a specific commit (Zig's compiler)
      {
        name = "zig",
        source = "github",
        owner = "ziglang",
        repo = "zig",
        ref = {
          type = "commit",
          name = "0e6f5d3e8a8b5f5d8c3c2b1a0f9e8d7c6b5a4f3e2"  -- Example commit hash
        }
      }
    }
  },

  -- System packages (installed with Homebrew)
  -- Package Management
  -- -----------------
  
  -- System Packages (installed via Homebrew)
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
      { name = "make" },
      { name = "cmake" },
      { name = "pkg-config" },
      
      -- CLI Tools
      { name = "ripgrep" },
      { name = "fd" },
      { name = "fzf" },
      { name = "bat" },
      { name = "eza" },
      { name = "zoxide" },
      { name = "jq" },
      { name = "yq" },
      { name = "htop" },
      { name = "tldr" },
      { name = "neofetch" },
      { name = "tmux" },
      { name = "wget" },
      { name = "curl" },
      { name = "git" },
      { name = "git-lfs" },
      { name = "gh" },
      { name = "hub" },
      { name = "lazygit" },
      
      -- Development Tools
      { name = "node" },
      { name = "yarn" },
      { name = "pnpm" },
      { name = "python@3.11" },
      { name = "go" },
      { name = "rustup" },
      { name = "zig" },
      { name = "zls" },
      { name = "llvm" },
      { name = "gcc" },
      { name = "clang-format" },
      
      -- Cloud & DevOps
      { name = "awscli" },
      { name = "azure-cli" },
      { name = "google-cloud-sdk" },
      { name = "kubectl" },
      { name = "kubectx" },
      { name = "helm" },
      { name = "terraform" },
      { name = "docker" },
      { name = "docker-compose" },
      { name = "vercel-cli" },
      { name = "supabase/tap/supabase" },
      { name = "railway" },
      
      -- Terminal & UI
      { name = "kitty" },
      { name = "wezterm" },
      { name = "alacritty" },
      { name = "skhd" },
      { name = "yabai" },
      
      -- Version Managers
      { name = "asdf" },
      { name = "nvm" },
      { name = "pyenv" },
      { name = "rbenv" },
      
      -- Security
      { name = "gnupg" },
      { name = "pinentry-mac" },
      { name = "openssl" },
      { name = "libssh2" },
      
      -- Database
      { name = "postgresql@14" },
      { name = "redis" },
      { name = "sqlite" },
      { name = "mongosh" },
      { name = "mysql" },
      
      -- Media
      { name = "ffmpeg" },
      { name = "imagemagick" },
      { name = "graphicsmagick" },
      
      -- Fonts
      { name = "font-fira-code" },
      { name = "font-hack-nerd-font" },
      { name = "font-jetbrains-mono" },
      
      -- Other
      { name = "neovim" },
      { name = "emacs" },
      { name = "vim" },
      { name = "zsh" },
      { name = "zsh-completions" },
      { name = "zsh-syntax-highlighting" },
      { name = "zsh-autosuggestions" },
      { name = "zsh-history-substring-search" }
    }
  },
  
  -- Node.js packages (installed with npm)
  node = {
    type = "npm",
    packages = {
      -- Package Managers
      { name = "npm" },
      { name = "yarn" },
      { name = "pnpm" },
      
      -- Development Tools
      { name = "typescript" },
      { name = "typescript-language-server" },
      { name = "eslint" },
      { name = "prettier" },
      { name = "ts-node" },
      { name = "nodemon" },
      { name = "tsx" },
      
      -- Runtimes
      { name = "node-gyp" },
      { name = "node-pre-gyp" },
      
      -- Build Tools
      { name = "webpack" },
      { name = "vite" },
      { name = "rollup" },
      { name = "esbuild" },
      { name = "swc" },
      { name = "swc-cli" },
      
      -- Testing
      { name = "jest" },
      { name = "mocha" },
      { name = "chai" },
      { name = "cypress" },
      { name = "playwright" },
      { name = "puppeteer" },
      
      -- Frameworks
      { name = "next" },
      { name = "react" },
      { name = "react-dom" },
      { name = "vue" },
      { name = "@vue/cli" },
      { name = "svelte" },
      { name = "@sveltejs/kit" },
      { name = "express" },
      { name = "fastify" },
      { name = "nest" },
      
      -- Utilities
      { name = "zx" },
      { name = "fkill" },
      { name = "http-server" },
      { name = "serve" },
      { name = "np" },
      { name = "npkill" },
      { name = "npx" },
      { name = "npm-check-updates" },
      { name = "depcheck" },
      { name = "madge" },
      { name = "@biomejs/biome" },
    }
  },
  
  -- Python packages (installed with pip)
  -- Python Environment
  python = {
    type = "pip",
    version = "3.10",  -- Specify Python version
    create_venv = true,  -- Create a virtual environment
    venv_path = ".venv",  -- Path to virtual environment
    requirements_file = "requirements.txt",  -- Optional requirements file
    
    packages = {
      -- Package Management
      { name = "pip", version = "latest" },
      { name = "pipx" },
      { name = "poetry" },
      { name = "pipenv" },
      { name = "pdm" },
      
      -- Development Tools
      { name = "setuptools" },
      { name = "wheel" },
      { name = "build" },
      { name = "twine" },
      { name = "virtualenv" },
      { name = "virtualenvwrapper" },
      { name = "pytest" },
      { name = "pytest-cov" },
      { name = "pytest-xdist" },
      { name = "pytest-mock" },
      { name = "coverage" },
      { name = "tox" },
      { name = "nox" },
      
      -- Code Quality
      { name = "black" },
      { name = "isort" },
      { name = "flake8" },
      { name = "mypy" },
      { name = "pylint" },
      { name = "pyright" },
      { name = "bandit" },
      { name = "safety" },
      { name = "pre-commit" },
      
      -- Data Science
      { name = "numpy" },
      { name = "pandas" },
      { name = "matplotlib" },
      { name = "seaborn" },
      { name = "scikit-learn" },
      { name = "tensorflow" },
      { name = "torch" },
      { name = "jupyter" },
      { name = "notebook" },
      { name = "ipython" },
      
      -- Web Development
      { name = "django" },
      { name = "flask" },
      { name = "fastapi" },
      { name = "uvicorn" },
      { name = "gunicorn" },
      { name = "django-rest-framework" },
      { name = "sqlalchemy" },
      { name = "alembic" },
      { name = "psycopg2-binary" },
      { name = "pymongo" },
      { name = "redis" },
      { name = "celery" },
      
      -- Utilities
      { name = "requests" },
      { name = "beautifulsoup4" },
      { name = "lxml" },
      { name = "pyyaml" },
      { name = "python-dotenv" },
      { name = "click" },
      { name = "typer" },
      { name = "rich" },
      { name = "tqdm" },
      { name = "loguru" }
    }
  },
  
  -- Rust tools (installed with cargo)
  rust = {
    type = "cargo",
    packages = {
      -- Core Tools
      { name = "rustup" },
      { name = "rustc" },
      { name = "cargo" },
      { name = "rustfmt" },
      { name = "clippy" },
      { name = "rust-analyzer" },
      
      -- Cargo Extensions
      { name = "cargo-edit" },
      { name = "cargo-watch" },
      { name = "cargo-expand" },
      { name = "cargo-update" },
      { name = "cargo-audit" },
      { name = "cargo-tarpaulin" },
      { name = "cargo-deny" },
      { name = "cargo-udeps" },
      { name = "cargo-make" },
      { name = "cargo-nextest" },
      { name = "cargo-bloat" },
      { name = "cargo-geiger" },
      { name = "cargo-msrv" },
      { name = "cargo-outdated" },
      { name = "cargo-release" },
      { name = "cargo-tree" },
      
      -- Development Tools
      { name = "rust-script" },
      { name = "evcxr_repl" },
      { name = "mdbook" },
      { name = "mdbook-pdf" },
      { name = "mdbook-toc" },
      { name = "mdbook-mermaid" },
      { name = "mdbook-graphviz" },
      { name = "mdbook-plantuml" },
      { name = "mdbook-linkcheck" },
      { name = "mdbook-tera" },
      { name = "mdbook-yml-header" },
      { name = "mdbook-yml-vars" }
    }
  },
  
  -- Custom installations
  custom = {
    -- Jetzig CLI (built from source)
    {
      name = "jetzig-cli",
      type = "script",
      script = [[
        if ! command -v jetzig &> /dev/null; then
          echo "Installing Jetzig CLI..."
          git clone https://github.com/jetzig-framework/jetzig.git /tmp/jetzig
          cd /tmp/jetzig
          zig build -Doptimize=ReleaseSafe
          mkdir -p ~/bin
          cp zig-out/bin/jetzig ~/bin/
          echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc
          echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
          echo "Jetzig CLI installed to ~/bin/jetzig"
          echo "Please restart your shell or run 'source ~/.zshrc'"
        else
          echo "Jetzig CLI is already installed"
        fi
      ]]
    },
    
    -- Configure shell
    {
      name = "shell-config",
      type = "script",
      script = [[
        # Add zoxide to shell
        if ! grep -q 'eval "$(zoxide init' ~/.zshrc 2>/dev/null; then
          echo 'eval "$(zoxide init zsh)"' >> ~/.zshrc
        fi
        
        # Add eza aliases
        if ! grep -q 'alias ls=' ~/.zshrc 2>/dev/null; then
          echo 'alias ls="eza --icons --group-directories-first"' >> ~/.zshrc
          echo 'alias ll="eza -l --icons --group-directories-first"' >> ~/.zshrc
          echo 'alias la="eza -la --icons --group-directories-first"' >> ~/.zshrc
        fi
        
        # Add bat to shell
        if ! grep -q 'alias cat=' ~/.zshrc 2>/dev/null; then
          echo 'alias cat="bat --theme=TwoDark"' >> ~/.zshrc
        fi
      ]]
    }
  }
}
