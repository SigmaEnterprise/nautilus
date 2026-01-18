#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

main() {
    # 1. Environment Variables
    HUGO_VERSION=0.147.7
    export TZ=Europe/Berlin
    
    # 2. Install Hugo Extended
    echo "Installing Hugo v${HUGO_VERSION}..."
    # We download the 'extended' version specifically for Blowfish/Sass support
    curl -LJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
    tar -xf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"
    
    # Move to a directory in the PATH or just use it locally
    # On Cloudflare, we can keep it in the root or /opt/buildhome
    mkdir -p bin
    mv hugo bin/hugo
    export PATH=$PATH:$(pwd)/bin
    
    # Cleanup
    rm LICENSE README.md "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"

    # 3. Verify installed versions
    echo "Verifying installations..."
    echo "Go: $(go version)"
    echo "Hugo: $(hugo version)"
    echo "Node.js: $(node --version)"

    # 4. Clone themes/submodules
    # This ensures your Blowfish theme is actually present before building
    echo "Updating submodules..."
    git submodule update --init --recursive
    git config core.quotepath false

    # 5. Building the website
    echo "Building the Site..."
    # If on Cloudflare, we use the provided URL, otherwise use a fallback
    BASE_URL=${CF_PAGES_URL:-"https://nautilus.ceronode.workers.dev/"}
    hugo --gc --minify --baseURL "$BASE_URL"
}

# Run the main function with all passed arguments
main "$@"
