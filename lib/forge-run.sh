#!/usr/bin/env bash

forge_run() {
    # Check if project is initialized
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    # Get output path
    local output=$(jq -r '.output' "$FORGE_CONFIG")
    
    # Build first if executable doesn't exist or sources are newer
    if [ ! -f "$output" ] || [ -n "$(find src -name "*.cpp" -newer "$output" 2>/dev/null)" ]; then
        info "Building project first..."
        source "$LIB_DIR/forge-build.sh"
        forge_build
        echo ""
    fi
    
    # Check if executable exists
    if [ ! -f "$output" ]; then
        error "Executable not found: $output"
    fi
    
    info "Running $output..."
    echo "────────────────────────────────────────"
    
    # Run the executable with any passed arguments
    "$output" "$@"
    local exit_code=$?
    
    echo "────────────────────────────────────────"
    
    if [ $exit_code -eq 0 ]; then
        success "Program exited successfully"
    else
        error "Program exited with code $exit_code"
    fi
}