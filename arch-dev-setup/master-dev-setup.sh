#!/bin/bash

# Master Development Environment Setup Script
# Dell Precision i9 10th Gen with NVIDIA T2000 Max-Q
# Archcraft Linux with complete development toolchain
# 
# This script incorporates all the latest work including:
# - Docker functionality verification after OS restart
# - asdf version management with proper error handling
# - GPU development optimization
# - Docker database container management
# - All helper scripts and aliases

set -e

# Source the functions library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/dev-setup-functions.sh"

# Main setup function
main() {
    print_phase "Archcraft Development Environment Master Setup"
    print_info "Dell Precision i9 10th Gen with NVIDIA T2000 Max-Q"
    print_info "Complete development environment with Docker, asdf, and GPU optimization"
    echo
    
    # Verify we're running on the correct system
    if ! command_exists nvidia-smi; then
        print_warning "NVIDIA drivers not detected. This script is optimized for NVIDIA systems."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Setup cancelled."
            exit 0
        fi
    fi
    
    # Phase 1: System Foundation
    print_phase "Phase 1: System Foundation"
    ensure_yay_installed
    update_system
    
    # Phase 2: Version Management Setup
    print_phase "Phase 2: Version Management (asdf)"
    setup_asdf
    
    # Phase 3: Development Languages and Frameworks
    print_phase "Phase 3: Development Languages"
    setup_dotnet
    setup_ruby
    setup_nodejs
    
    # Phase 4: Containerization and Databases
    print_phase "Phase 4: Docker and Database Setup"
    setup_docker
    setup_databases
    
    # Verify Docker is working after our setup
    print_step "Verifying Docker functionality"
    if docker info >/dev/null 2>&1; then
        print_success "Docker is running and accessible"
        
        # Test with hello-world if Docker is working
        if docker run --rm hello-world >/dev/null 2>&1; then
            print_success "Docker container execution verified"
        else
            print_warning "Docker is running but container execution may require reboot/logout"
        fi
    else
        print_warning "Docker setup complete but may require logout/reboot to activate group membership"
    fi
    
    # Phase 5: IDEs and Development Tools
    print_phase "Phase 5: IDEs and Development Tools"
    setup_ides
    setup_development_tools
    
    # Phase 6: GPU Optimization
    print_phase "Phase 6: GPU Development Optimization"
    if command_exists nvidia-smi; then
        setup_gpu_development
        print_step "Testing GPU switching capability"
        if command_exists prime-run; then
            if prime-run glxinfo | grep -q "OpenGL renderer"; then
                print_success "GPU switching (prime-run) is functional"
            else
                print_warning "GPU switching available but may need graphics restart"
            fi
        else
            print_warning "nvidia-prime not installed. Install with: sudo pacman -S nvidia-prime"
        fi
    else
        print_info "Skipping GPU setup - NVIDIA drivers not detected"
    fi
    
    # Phase 7: System Utilities and Monitoring
    print_phase "Phase 7: System Utilities"
    setup_fonts
    setup_monitoring
    setup_backup_tools
    
    # Phase 8: Helper Scripts and Configuration
    print_phase "Phase 8: Helper Scripts and Configuration"
    create_asdf_helper
    create_docker_db_helper
    create_update_script
    configure_git
    setup_development_aliases
    
    # Phase 9: Final Verification and Summary
    print_phase "Phase 9: System Verification"
    verify_installation
    print_completion_summary
}

# Verification function
verify_installation() {
    print_step "Verifying installation components"
    
    local components_ok=true
    
    # Check essential tools
    for tool in git curl wget vim; do
        if command_exists "$tool"; then
            print_success "✓ $tool installed"
        else
            print_error "✗ $tool missing"
            components_ok=false
        fi
    done
    
    # Check asdf
    if command_exists asdf; then
        print_success "✓ asdf version manager installed"
        local plugins=$(asdf plugin list 2>/dev/null | tr '\n' ' ')
        if [ -n "$plugins" ]; then
            print_info "  Plugins: $plugins"
        fi
    else
        print_error "✗ asdf not available"
        components_ok=false
    fi
    
    # Check Docker
    if command_exists docker; then
        print_success "✓ Docker installed"
        if docker info >/dev/null 2>&1; then
            print_success "✓ Docker daemon accessible"
        else
            print_warning "! Docker installed but daemon not accessible (may need logout/reboot)"
        fi
    else
        print_error "✗ Docker missing"
        components_ok=false
    fi
    
    # Check development tools
    local dev_tools=("code" "dotnet" "yay")
    for tool in "${dev_tools[@]}"; do
        if command_exists "$tool"; then
            print_success "✓ $tool available"
        else
            print_warning "! $tool not found (may need manual installation)"
        fi
    done
    
    # Check helper scripts
    local scripts=("$HOME/asdf-helper.sh" "$HOME/docker-db-helper.sh" "$HOME/update-system.sh")
    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            print_success "✓ $(basename "$script") created and executable"
        else
            print_warning "! $(basename "$script") missing or not executable"
        fi
    done
    
    # Check GPU setup if NVIDIA present
    if command_exists nvidia-smi; then
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits 2>/dev/null || echo "unknown")
        print_success "✓ NVIDIA drivers active (version: $driver_version)"
        
        if command_exists prime-run; then
            print_success "✓ GPU switching (prime-run) available"
        else
            print_warning "! GPU switching not available (install nvidia-prime)"
        fi
    fi
    
    if $components_ok; then
        print_success "All core components verified successfully"
    else
        print_warning "Some components need attention - see messages above"
    fi
}

# Helper script creation with latest updates
create_update_script() {
    local script_path="$HOME/update-system.sh"
    
    if [ -f "$script_path" ]; then
        print_info "Update script already exists - updating with latest version"
    else
        print_step "Creating system update script"
    fi
    
    cat > "$script_path" << 'EOF'
#!/bin/bash

# System Update Script for Archcraft Development Environment
# Updated with Docker and asdf support verification

echo "=== System Update Started ==="
echo

# Update system packages
echo "Updating system packages..."
if sudo pacman -Syu; then
    echo "✓ System packages updated"
else
    echo "✗ System package update failed"
    exit 1
fi

# Update AUR packages
echo "Updating AUR packages..."
if command -v yay >/dev/null 2>&1; then
    if yay -Syu; then
        echo "✓ AUR packages updated"
    else
        echo "✗ AUR package update failed"
    fi
else
    echo "! yay not available - skipping AUR updates"
fi

# Update asdf plugins
echo "Updating asdf plugins..."
if command -v asdf >/dev/null 2>&1; then
    if asdf plugin update --all; then
        echo "✓ asdf plugins updated"
    else
        echo "! asdf plugin update had issues (may be normal)"
    fi
else
    echo "! asdf not available - skipping plugin updates"
fi

# Docker system cleanup
echo "Cleaning Docker system..."
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    if docker system prune -f; then
        echo "✓ Docker system cleaned"
    else
        echo "! Docker cleanup had issues"
    fi
else
    echo "! Docker not accessible - skipping Docker cleanup"
fi

# Clean package cache
echo "Cleaning package cache..."
if sudo pacman -Sc --noconfirm; then
    echo "✓ Package cache cleaned"
else
    echo "! Package cache cleanup failed"
fi

echo
echo "=== System Update Complete ==="
echo "Consider rebooting if kernel or drivers were updated"
EOF
    
    chmod +x "$script_path"
    print_success "System update script created: $script_path"
}

# Error handling
trap 'print_error "Setup interrupted. Some components may be partially installed."' INT TERM

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user with sudo access."
    exit 1
fi

# Check for required commands
if ! command_exists sudo; then
    print_error "sudo is required but not available"
    exit 1
fi

if ! command_exists git; then
    print_error "git is required but not available. Install with: sudo pacman -S git"
    exit 1
fi

# Run main setup
main "$@"

print_phase "Master Setup Complete!"
print_info "Your development environment is ready for:"
echo "• .NET development with Entity Framework"
echo "• Ruby on Rails development" 
echo "• Node.js and modern web frameworks"
echo "• Docker containerized development"
echo "• GPU-accelerated development tools"
echo "• Multi-language version management with asdf"
echo
print_info "Important next steps:"
echo "1. Reboot or logout/login to activate all group memberships"
echo "2. Test Docker: docker run --rm hello-world"
echo "3. Test GPU switching: prime-run glxinfo | grep 'OpenGL renderer'"
echo "4. Source shell config: source ~/.zshrc"
echo "5. Create system backup: sudo timeshift --create --comments 'Complete dev setup'"
echo
print_info "Helper commands:"
echo "• ./asdf-helper.sh - Manage programming language versions"
echo "• ./docker-db-helper.sh - Manage development databases"
echo "• ./update-system.sh - Keep your system updated"
echo "• db-postgres, db-mysql, db-redis, db-mongo - Quick database aliases"
