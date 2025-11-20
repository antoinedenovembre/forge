# Commands

## `forge init [name]`
Initialize a new C++ project.

```bash
# Create new project in a new directory
forge init my_app

# Initialize in current directory
cd existing_project
forge init
```

Creates the following structure:
```
my_project/
├── forge.json      # Project configuration
├── src/            # Source files (.cpp)
├── include/        # Header files (.h, .hpp)
├── libs/           # Dependencies
├── build/          # Compiled output
└── tests/          # Test files
```

## `forge install [name] [url]`
Manage project dependencies.

```bash
# Install a specific dependency
forge install fmt https://github.com/fmtlib/fmt.git

# Install all dependencies from forge.json
forge install
```

Dependencies are cloned into `libs/` and automatically included during compilation.

## `forge build`
Compile your project.

```bash
forge build
```

Compiles all `.cpp` files in `src/` according to your `forge.json` configuration.

## `forge run [args...]`
Build (if needed) and run your project.

```bash
forge run
forge run --arg1 value1  # Pass arguments to your program
```

## `forge clean`
Remove build artifacts.

```bash
forge clean
```