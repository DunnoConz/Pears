# Contributing to Pears

Thank you for your interest in contributing to Pears! We welcome contributions from the community to help improve this project.

## How to Contribute

### Reporting Issues

If you find a bug or have a feature request, please [open an issue](https://github.com/yourusername/pears/issues) with the following information:

- A clear title and description
- Steps to reproduce the issue (if applicable)
- Expected vs. actual behavior
- Your operating system and version
- Any relevant error messages or logs

### Submitting Pull Requests

1. Fork the repository and create your feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```

2. Make your changes and ensure tests pass:
   ```bash
   zig build test
   ```

3. Ensure your code follows the project's style guidelines:
   - Use `zig fmt` to format your code
   - Add documentation for new features
   - Include tests for new functionality

4. Commit your changes with a descriptive commit message:
   ```bash
   git commit -m "feat: add amazing feature"
   ```

5. Push to your fork and open a pull request

## Development Setup

### Prerequisites

- Zig (latest stable version)
- Lua 5.4+
- Git

### Building from Source

```bash
git clone https://github.com/yourusername/pears.git
cd pears
zig build -Doptimize=ReleaseSafe
```

### Running Tests

```bash
zig build test
```

## Code Style

- Use 4 spaces for indentation
- Follow Zig's naming conventions:
  - `snake_case` for variables and functions
  - `PascalCase` for types
  - `UPPER_SNAKE_CASE` for constants
- Keep lines under 100 characters when possible
- Add comments to explain complex logic

## Commit Message Guidelines

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Changes that do not affect the meaning of the code
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `perf:` A code change that improves performance
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to the build process or auxiliary tools

## License

By contributing to Pears, you agree that your contributions will be licensed under the [MIT License](LICENSE).
