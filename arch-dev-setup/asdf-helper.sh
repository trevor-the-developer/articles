#!/bin/bash

# asdf Version Management Helper for Development Environment

echo "=== asdf Version Management Helper ==="
echo

case "${1:-help}" in
    "ruby")
        echo "Available Ruby versions:"
        asdf list all ruby | tail -20
        echo
        echo "Install Ruby version: asdf install ruby <version>"
        echo "Set global Ruby: asdf global ruby <version>"
        echo "Set local Ruby: asdf local ruby <version>"
        ;;
    "node")
        echo "Available Node.js versions:"
        asdf list all nodejs | tail -20
        echo
        echo "Install Node.js version: asdf install nodejs <version>"
        echo "Set global Node.js: asdf global nodejs <version>"
        echo "Set local Node.js: asdf local nodejs <version>"
        ;;
    "python")
        echo "Installing Python plugin..."
        asdf plugin add python
        echo "Available Python versions:"
        asdf list all python | tail -20
        echo
        echo "Install Python version: asdf install python <version>"
        echo "Set global Python: asdf global python <version>"
        echo "Set local Python: asdf local python <version>"
        ;;
    "status")
        echo "Currently installed versions:"
        asdf current
        echo
        echo "Installed plugins:"
        asdf plugin list
        ;;
    "add-plugin")
        if [ -z "$2" ]; then
            echo "Usage: $0 add-plugin <plugin-name>"
            echo "Example: $0 add-plugin python"
            exit 1
        fi
        echo "Adding plugin: $2"
        asdf plugin add $2
        ;;
    *)
        echo "Usage: $0 [ruby|node|python|status|add-plugin]"
        echo
        echo "Commands:"
        echo "  ruby      - Show Ruby version management commands"
        echo "  node      - Show Node.js version management commands" 
        echo "  python    - Install Python plugin and show commands"
        echo "  status    - Show current versions and installed plugins"
        echo "  add-plugin <name> - Add a new asdf plugin"
        echo
        echo "Common asdf commands:"
        echo "  asdf list all <plugin>     - List all available versions"
        echo "  asdf install <plugin> <version> - Install a specific version"
        echo "  asdf global <plugin> <version>  - Set global version"
        echo "  asdf local <plugin> <version>   - Set local version (project-specific)"
        echo "  asdf current              - Show current versions"
        echo "  asdf plugin list          - List installed plugins"
        ;;
esac
