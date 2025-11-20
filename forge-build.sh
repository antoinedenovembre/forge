#!/usr/bin/env bash

forge_build() {
    # Check if project is initialized
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    info "Reading project configuration..."
    
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