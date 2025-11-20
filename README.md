# Forge

A modern, Node.js-inspired dependency manager and build tool for C++ projects.

## Features

- 🚀 **Simple project initialization** - Get started in seconds
- 📦 **Git-based dependency management** - Install libraries directly from GitHub
- ⚡ **Smart rebuilds** - Only recompile when sources change
- 🎯 **Zero configuration** - Sensible defaults, customizable when needed
- 🧹 **Clean project structure** - Organized folders for sources, headers, and dependencies

## Installation

```bash
git clone https://github.com/antoinedenovembre/forge.git
cd forge
./install.sh
```

This will install `forge` to `/usr/local/bin` (requires sudo).

## Quick Start

```bash
# Create a new project
forge init my_project
cd my_project

# Install dependencies
forge install json https://github.com/nlohmann/json.git
forge install fmt https://github.com/fmtlib/fmt.git

# Build and run
forge build
forge run
```

## Commands

See [COMMANDS.md](doc/COMMANDS.md) for detailed command usage.

## Configuration

See [CONFIG.md](doc/CONFIG.md) for configuration options.

## Example Project

```cpp
// src/main.cpp
#include <iostream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

int main() {
    json config = {
        {"project", "forge"},
        {"awesome", true}
    };
    
    std::cout << config.dump(2) << std::endl;
    return 0;
}
```

```bash
forge install json https://github.com/nlohmann/json.git
forge run
```

## Requirements

- Bash 4.0+
- Git
- `jq` (for JSON parsing)
- C++ compiler (`g++` or `clang++`)

### Installing dependencies

**Ubuntu/Debian:**
```bash
sudo apt install git jq g++
```

**macOS:**
```bash
brew install git jq
```

## Roadmap

- [ ] CMake integration for complex projects
- [x] Unit testing support (`forge test`)
- [ ] Version pinning for dependencies
- [ ] Project templates (CLI, library, game)
- [ ] Publishing system
- [ ] Dependency update command

## Contributing

Contributions are welcome! Feel free to open issues or submit PRs.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Inspired by npm (Node.js), Cargo (Rust), and the need for simpler C++ project management.