#!/usr/bin/env bash

forge_install() {
    if [ ! -f "$FORGE_CONFIG" ]; then
        error "No forge.json found. Run 'forge init' first."
    fi
    
    local dep_name="$1"
    local dep_url="$2"
    
    # Case 1: forge install (no args) → install all dependencies from forge.json
    if [ -z "$dep_name" ]; then
        info "Installing all dependencies..."
        
        local deps=$(jq -r '.dependencies | to_entries | .[] | .key + " " + .value' "$FORGE_CONFIG")
        
        if [ -z "$deps" ]; then
            info "No dependencies to install"
            return 0
        fi
        
        while IFS= read -r line; do
            local name=$(echo "$line" | awk '{print $1}')
            local url=$(echo "$line" | awk '{print $2}')
            _install_dependency "$name" "$url"
        done <<< "$deps"
        
        success "All dependencies installed"
        return 0
    fi
    
    # Case 2: forge install <name> <url> → install and save to forge.json
    if [ -z "$dep_url" ]; then
        error "Usage: forge install <name> <git-url>"
    fi
    
    _install_dependency "$dep_name" "$dep_url"
    
    # Add to forge.json
    local tmp=$(mktemp)
    jq ".dependencies[\"$dep_name\"] = \"$dep_url\"" "$FORGE_CONFIG" > "$tmp"
    mv "$tmp" "$FORGE_CONFIG"
    
    success "Dependency '$dep_name' added to forge.json"
}

_install_dependency() {
    local name="$1"
    local url="$2"
    
    local lib_path="libs/$name"
    
    # Skip if already installed and not empty
    if [ -d "$lib_path" ] && [ "$(ls -A "$lib_path" 2>/dev/null)" ]; then
        info "Dependency '$name' already installed, skipping..."
        return 0
    fi
    
    info "Installing $name from $url..."
    
    # Create libs directory if it doesn't exist
    mkdir -p libs
    
    # Remove potentially empty directory
    rm -rf "$lib_path"
    
    # Clone the repository
    if git clone --depth 1 --quiet "$url" "$lib_path" 2>&1; then
        # Remove .git to save space
        rm -rf "$lib_path/.git"
        success "Installed $name"
    else
        # Clean up failed installation
        rm -rf "$lib_path"
        error "Failed to install $name from $url"
    fi
}