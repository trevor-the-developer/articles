#!/bin/bash

# Main Development Environment Setup Script
# Dell Precision i9 10th Gen - Archcraft Linux
# Using modular functions for clean, maintainable setup

set -e

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the functions library
if [ -f "$SCRIPT_DIR/dev-setup-functions.sh" ]; then
    source "$SCRIPT_DIR/dev-setup-functions.sh"
else
    echo "Error: dev-setup-functions.sh not found in $SCRIPT_DIR"
    echo "Please ensure both scripts are in the same directory."
    exit 1
fi

# Helper function to ensure asdf is loaded for individual language setups
ensure_asdf_loaded() {
    if ! command_exists asdf; then
        print_warning "asdf not found, setting it up first..."
        setup_asdf
    fi
}

# Main setup function
main() {
    print_phase "Development Environment Setup for Dell Precision i9 10th Gen"
    print_info "Based on your dev-setup-guide.md"
    print_info "System detected: Archcraft Linux with NVIDIA T2000 Max-Q"
    print_info "Using asdf for multi-language version management"
    print_info "Using Docker-only approach for databases"
    echo

    # Phase 1: System preparation
    print_phase "Phase 1: System Preparation"
    ensure_yay_installed
    update_system

    # Phase 2: Version management setup  
    print_phase "Phase 2: Version Management Setup"
    setup_asdf

    # Phase 3: Development languages
    print_phase "Phase 3: Development Languages"
    setup_dotnet
    setup_ruby
    setup_nodejs

    # Phase 4: IDEs and editors
    print_phase "Phase 4: IDEs and Editors"
    setup_ides

    # Phase 5: Database tools (Docker-only)
    print_phase "Phase 5: Database Tools"
    setup_databases

    # Phase 6: Development tools
    print_phase "Phase 6: Development Tools"
    setup_development_tools
    setup_docker

    # Phase 7: GPU and system optimization
    print_phase "Phase 7: System Optimization"
    setup_gpu_development
    setup_fonts
    setup_monitoring
    setup_backup_tools

    # Phase 8: Configuration and helpers
    print_phase "Phase 8: Configuration and Helper Scripts"
    configure_git
    create_asdf_helper
    create_docker_db_helper
    create_update_script
    add_shell_aliases

    # Phase 9: Completion
    print_completion_summary
}

# Command line options
case "${1:-main}" in
    "main"|"")
        main
        ;;
    "asdf")
        print_phase "Setting up asdf version manager only"
        setup_asdf
        ;;
    "dotnet")
        print_phase "Setting up .NET development only"
        setup_dotnet
        ;;
    "ruby")
        print_phase "Setting up Ruby development only"
        ensure_asdf_loaded
        setup_ruby
        ;;
    "nodejs"|"node")
        print_phase "Setting up Node.js development only"
        ensure_asdf_loaded
        setup_nodejs
        ;;
    "docker")
        print_phase "Setting up Docker only"
        setup_docker
        ;;
    "ides")
        print_phase "Setting up IDEs and editors only"
        setup_ides
        ;;
    "databases"|"db")
        print_phase "Setting up database tools only"
        setup_databases
        ;;
    "gpu")
        print_phase "Setting up GPU development only"
        setup_gpu_development
        ;;
    "helpers")
        print_phase "Creating helper scripts only"
        create_asdf_helper
        create_docker_db_helper
        create_update_script
        ;;
    "test")
        print_phase "Testing functions library"
        print_info "Functions library loaded successfully"
        print_success "All functions available"
        ;;
    "help"|"-h"|"--help")
        echo "Development Environment Setup Script"
        echo "Usage: $0 [command]"
        echo
        echo "Commands:"
        echo "  main (default) - Run complete development environment setup"
        echo "  asdf          - Setup asdf version manager only"
        echo "  dotnet        - Setup .NET development only"
        echo "  ruby          - Setup Ruby development only"
        echo "  nodejs        - Setup Node.js development only"
        echo "  docker        - Setup Docker only"
        echo "  ides          - Setup IDEs and editors only"
        echo "  databases     - Setup database tools only"
        echo "  gpu           - Setup GPU development only"
        echo "  helpers       - Create helper scripts only"
        echo "  test          - Test functions library loading"
        echo "  help          - Show this help message"
        echo
        echo "Examples:"
        echo "  $0              # Run complete setup"
        echo "  $0 ruby         # Setup Ruby development only"
        echo "  $0 docker       # Setup Docker only"
        echo
        echo "Note: Some components depend on others (e.g., Ruby/Node.js require asdf)"
        ;;
    *)
        print_error "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac

