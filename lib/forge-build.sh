#!/usr/bin/env bash

forge_build() {
    # Check if project is initialized
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    info "Reading project configuration..."
    
    # Check if project uses CMake (either from forge.json or CMakeLists.txt exists)
    local use_cmake=$(jq -r '.use_cmake' "$FORGE_CONFIG" 2>/dev/null)
    
    if [ "$use_cmake" = "true" ] || [ -f "CMakeLists.txt" ]; then
        _build_with_cmake
    else
        _build_direct
    fi
}

_build_with_cmake() {
    info "Building with CMake..."
    
    # Check if cmake is installed
    if ! command -v cmake >/dev/null 2>&1; then
        error "CMake not found. Install with: apt install cmake / brew install cmake"
    fi
    
    local project_name=$(jq -r '.name' "$FORGE_CONFIG")
    local output=$(jq -r '.output' "$FORGE_CONFIG")
    
    # Create build directory
    mkdir -p build
    cd build || error "Failed to enter build directory"
    
    info "Running CMake configuration..."
    if cmake -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=. .. 2>&1; then
        success "CMake configuration successful"
    else
        cd ..
        error "CMake configuration failed"
    fi
    
    info "Compiling..."
    if cmake --build . 2>&1 | grep -v "Scanning dependencies\|Built target"; then
        cd ..
        
        # Move executable to expected location if needed
        if [ -f "build/$project_name" ] && [ "$output" != "build/$project_name" ]; then
            mkdir -p "$(dirname "$output")"
            mv "build/$project_name" "$output"
        fi
        
        success "Build successful: $output"
    else
        cd ..
        error "Build failed"
    fi
    
    cd ..
}

_build_direct() {
    # Parse forge.json
    local project_name=$(jq -r '.name' "$FORGE_CONFIG")
    local compiler=$(jq -r '.compiler' "$FORGE_CONFIG")
    local std=$(jq -r '.std' "$FORGE_CONFIG")
    local output=$(jq -r '.output' "$FORGE_CONFIG")
    local flags=$(jq -r '.flags | join(" ")' "$FORGE_CONFIG")
    local include_dirs=$(jq -r '.include_dirs | map("-I" + .) | join(" ")' "$FORGE_CONFIG")
    
    info "Building $project_name..."
    
    # Create build directory if it doesn't exist
    mkdir -p "$(dirname "$output")"
    
    # Find all .cpp files in src/
    local source_files=$(find src -name "*.cpp" 2>/dev/null)
    
    if [ -z "$source_files" ]; then
        error "No .cpp files found in src/"
    fi
    
    # Add libs include directories
    local libs_includes=""
    if [ -d "libs" ]; then
        for lib in libs/*; do
            if [ -d "$lib/include" ]; then
                libs_includes="$libs_includes -I$lib/include"
            fi
        done
    fi
    
    # Build command
    local build_cmd="$compiler -std=$std $flags $include_dirs $libs_includes $source_files -o $output"
    
    echo "  $build_cmd"
    
    # Execute build
    if $build_cmd 2>&1; then
        success "Build successful: $output"
    else
        error "Build failed"
    fi
}