#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

main() {
    # 1. Configuration: Pin versions for 2026 compatibility
    HUGO_VERSION="0.154.5"
    export TZ="Europe/Berlin"
    
    echo "--- Sovereign Build Started: Nautilus ---"

    # 2. Install Hugo Extended (Required for Blowfish SCSS/Tailwind)
    echo "Installing Hugo Extended v${HUGO_VERSION}..."
    TARBALL="hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
    URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${TARBALL}"
    
    curl -LJO "$URL"
    tar -xf "$TARBALL"
    
    # Setup local bin directory
    mkdir -p bin
    mv hugo bin/hugo
    export PATH="$(pwd)/bin:$PATH"
    
    # Cleanup installation files
    rm LICENSE README.md "$TARBALL"

    # 3. Verify Version (Crucial for debugging logs)
    echo "Using Hugo: $(hugo version)"

    # 4. Handle Submodules (Fixes missing theme components)
    echo "Synchronizing Blowfish theme..."
    git submodule update --init --recursive
    git config core.quotepath false

    # 5. Build the Site
    # Using --gc (garbage collection) ensures a clean state
    # Using the trailing slash in baseURL is vital for asset paths
    echo "Generating static assets..."
    BASE_URL=${CF_PAGES_URL:-"https://nautilus.ceronode.workers.dev/"}
    
    hugo --gc --minify --baseURL "$BASE_URL"

    # 6. Final verification of output
    if [ -d "public" ] && [ "$(ls -A public)" ]; then
        echo "--- Success: Site built in /public ---"
    else
        echo "Error: /public directory is empty or missing!"
        exit 1
    fi
}

main "$@"
