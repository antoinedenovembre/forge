# Configuration

The `forge.json` file controls your project settings:

```json
{
  "name": "my_project",
  "version": "0.1.0",
  "description": "",
  "author": "",
  "dependencies": {
    "fmt": "https://github.com/fmtlib/fmt.git",
    "json": "https://github.com/nlohmann/json.git"
  },
  "compiler": "g++",
  "std": "c++17",
  "flags": ["-Wall", "-Wextra", "-O2"],
  "include_dirs": ["include"],
  "output": "build/my_project"
}
```

## Configuration Options

- **name**: Project name
- **version**: Project version (semver)
- **dependencies**: Map of dependency names to Git URLs
- **compiler**: C++ compiler to use (`g++`, `clang++`)
- **std**: C++ standard (`c++11`, `c++14`, `c++17`, `c++20`, `c++23`)
- **flags**: Compiler flags (warnings, optimizations, etc.)
- **include_dirs**: Additional include directories
- **output**: Path to compiled executable