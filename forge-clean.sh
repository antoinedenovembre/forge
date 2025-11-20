#!/usr/bin/env bash

forge_clean() {
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    info "Cleaning build artifacts..."
    
    # Remove build directory
    if [ -d "build" ]; then
        rm -rf build/*
        success "Cleaned build/"
    fi
    
    # Remove .o files
    find . -name "*.o" -type f -delete 2>/dev/null
    find . -name "*.out" -type f -delete 2>/dev/null
    
    success "Clean complete"
}