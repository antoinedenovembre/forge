#!/usr/bin/env bash

forge_init() {
    local project_name="$1"
    local use_cmake=false

    # Validate project name
    if [ "$project_name" = "test" ]; then
        error "Project name 'test' is reserved by CMake. Please choose another name."
    fi
    
    # Case 1: forge init (no args) → initialize in current directory
    if [ -z "$project_name" ]; then
        if [ -f "$FORGE_CONFIG" ]; then
            error "Project already initialized (forge.json exists)"
        fi
        
        project_name=$(basename "$PWD")
        info "Initializing project in current directory: $project_name"
        
        # Ask about CMake
        _ask_cmake
        use_cmake=$?
        
        _create_project_structure "$project_name" "$use_cmake"
        
    # Case 2: forge init my_project → create new directory
    else
        if [ -d "$project_name" ]; then
            error "Directory '$project_name' already exists"
        fi
        
        info "Creating project: $project_name"
        
        # Ask about CMake
        _ask_cmake
        use_cmake=$?
        
        mkdir "$project_name"
        cd "$project_name" || error "Failed to enter project directory"
        _create_project_structure "$project_name" "$use_cmake"
        
        echo ""
        info "Next steps:"
        echo "  cd $project_name"
        echo "  forge build"
        echo "  forge run"
    fi
}

_ask_cmake() {
    echo ""
    read -p "Use CMake for this project? (y/N): " choice
    case "$choice" in 
        y|Y|yes|Yes|YES ) return 0;;
        * ) return 1;;
    esac
}

_create_project_structure() {
    local project_name="$1"
    local use_cmake="$2"
    
    # Create directory structure
    mkdir -p src include libs build tests
    
    # Create forge.json
    cat > "$FORGE_CONFIG" << EOF
{
  "name": "$project_name",
  "version": "0.1.0",
  "description": "",
  "author": "",
  "dependencies": {},
  "compiler": "g++",
  "std": "c++17",
  "flags": ["-Wall", "-Wextra"],
  "include_dirs": ["include"],
  "output": "build/$project_name",
  "use_cmake": $use_cmake
}
EOF
    
    # Create main.cpp
    cat > src/main.cpp << 'EOF'
#include <iostream>

int main() {
    std::cout << "Hello from Forge!" << std::endl;
    return 0;
}
EOF
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
build/
libs/
*.o
*.out
.DS_Store
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile
EOF
    
    # Generate CMakeLists.txt if requested
    if [ "$use_cmake" = "0" ]; then
        _generate_cmake "$project_name"
        success "Project initialized with CMake!"
    else
        success "Project initialized!"
    fi
}

_generate_cmake() {
    local project_name="$1"
    local std=$(jq -r '.std' "$FORGE_CONFIG" 2>/dev/null || echo "c++17")
    local std_version="${std//c++/}"
    
    cat > CMakeLists.txt << EOF
cmake_minimum_required(VERSION 3.10)
project($project_name)

# Set C++ standard
set(CMAKE_CXX_STANDARD $std_version)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler flags
add_compile_options(-Wall -Wextra)

# Include directories
include_directories(include)

# Add libs include directories
file(GLOB LIB_DIRS "libs/*/include")
include_directories(\${LIB_DIRS})

# Collect all source files from src/
file(GLOB_RECURSE SOURCES "src/*.cpp")

# Also collect source files from libs if they exist
file(GLOB_RECURSE LIB_SOURCES "libs/*/src/*.cpp")
list(APPEND SOURCES \${LIB_SOURCES})

# Create executable with suffix to avoid name conflicts
add_executable(${project_name}_exe \${SOURCES})

# Rename output to project name
set_target_properties(${project_name}_exe PROPERTIES
    OUTPUT_NAME "$project_name"
    RUNTIME_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/build"
)

# Enable testing
enable_testing()

# Find all test files
file(GLOB TEST_SOURCES "tests/*_test.cpp" "tests/test_*.cpp")

foreach(test_src \${TEST_SOURCES})
    get_filename_component(test_name \${test_src} NAME_WE)
    add_executable(\${test_name}_exe \${test_src})
    set_target_properties(\${test_name}_exe PROPERTIES
        OUTPUT_NAME "\${test_name}"
        RUNTIME_OUTPUT_DIRECTORY "\${CMAKE_SOURCE_DIR}/build/tests"
    )
    add_test(NAME \${test_name} COMMAND \${test_name}_exe)
endforeach()
EOF
}