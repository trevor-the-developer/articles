#!/bin/bash

# Development Setup Functions Library
# Common functions for setting up development environment on Dell Precision i9 10th Gen

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print functions
print_phase() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    echo -e "${CYAN}[DEBUG]${NC} $1"
}

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    pacman -Qi "$1" >/dev/null 2>&1
}

aur_package_installed() {
    yay -Qi "$1" >/dev/null 2>&1
}

# System functions
ensure_yay_installed() {
    if ! command_exists yay; then
        print_step "Installing AUR helper (yay)"
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay
        makepkg -si --noconfirm
        cd - && rm -rf /tmp/yay
    else
        print_info "AUR helper (yay) already installed"
    fi
}

update_system() {
    print_step "Updating system packages"
    sudo pacman -Syu --noconfirm
}

# asdf functions
setup_asdf() {
    print_step "Installing asdf version manager"
    
    if ! command_exists asdf; then
        yay -S --noconfirm asdf-vm
    else
        print_info "asdf already installed"
    fi
    
    # Check if this is a binary installation (newer asdf-vm package)
    if [ -x "/usr/bin/asdf" ]; then
        print_step "Configuring asdf binary for zsh"
        
        # Add to shell profile if not already present
        if ! grep -q "asdf" ~/.zshrc 2>/dev/null; then
            cat >> ~/.zshrc << 'EOF'

# asdf version manager (binary installation)
# Enable asdf completions
if [ -f /usr/share/zsh/site-functions/_asdf ]; then
    fpath=(${ASDF_DIR}/completions $fpath)
    autoload -Uz compinit && compinit
fi
EOF
        else
            print_info "asdf already configured in ~/.zshrc"
        fi
        
        print_success "asdf binary setup complete"
        return 0
    fi
    
    # Fall back to shell script installation method
    local asdf_path
    if [ -f "/usr/share/asdf-vm/asdf.sh" ]; then
        asdf_path="/usr/share/asdf-vm/asdf.sh"
    elif [ -f "/opt/asdf-vm/asdf.sh" ]; then
        asdf_path="/opt/asdf-vm/asdf.sh"
    elif [ -f "/usr/share/asdf/asdf.sh" ]; then
        asdf_path="/usr/share/asdf/asdf.sh"
    else
        print_error "Could not find asdf installation (neither binary nor shell script)"
        return 1
    fi
    
    print_step "Configuring asdf shell script for zsh (path: $asdf_path)"
    
    # Add to shell profile if not already present
    if ! grep -q "asdf" ~/.zshrc 2>/dev/null; then
        cat >> ~/.zshrc << EOF

# asdf version manager
. $asdf_path
EOF
    else
        print_info "asdf already configured in ~/.zshrc"
    fi
    
    # Source asdf for current session
    . "$asdf_path"
    
    print_success "asdf setup complete"
}

install_asdf_plugin() {
    local plugin="$1"
    local repo="$2"
    
    print_step "Installing asdf plugin: $plugin"
    
    if asdf plugin list | grep -q "^$plugin$"; then
        print_info "Plugin $plugin already installed"
    else
        if [ -n "$repo" ]; then
            asdf plugin add "$plugin" "$repo"
        else
            asdf plugin add "$plugin"
        fi
        print_success "Plugin $plugin installed"
    fi
}

install_language_version() {
    local language="$1"
    local version="$2"
    
    print_step "Installing $language $version"
    
    if asdf list "$language" 2>/dev/null | grep -q "$version"; then
        print_info "$language $version already installed"
    else
        asdf install "$language" "$version"
        print_success "$language $version installed"
    fi
    
    # Use 'set' command for newer asdf versions
    if asdf set "$language" "$version" 2>/dev/null; then
        print_info "Set $language global version to $version (using asdf set)"
    elif asdf global "$language" "$version" 2>/dev/null; then
        print_info "Set $language global version to $version (using asdf global)"
    else
        print_warning "Could not set global version for $language. You may need to set it manually."
    fi
}

# Package installation functions
install_pacman_packages() {
    local packages=("$@")
    local to_install=()
    
    for package in "${packages[@]}"; do
        if ! package_installed "$package"; then
            to_install+=("$package")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        print_step "Installing packages: ${to_install[*]}"
        sudo pacman -S --noconfirm "${to_install[@]}"
    else
        print_info "All specified packages already installed"
    fi
}

install_aur_packages() {
    local packages=("$@")
    local to_install=()
    
    for package in "${packages[@]}"; do
        if ! aur_package_installed "$package"; then
            to_install+=("$package")
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        print_step "Installing AUR packages: ${to_install[*]}"
        yay -S --noconfirm "${to_install[@]}"
    else
        print_info "All specified AUR packages already installed"
    fi
}

# Development environment functions
setup_dotnet() {
    print_step "Setting up .NET development environment"
    
    install_pacman_packages dotnet-sdk dotnet-runtime
    
    if ! command_exists dotnet-ef; then
        print_step "Installing Entity Framework tools"
        dotnet tool install --global dotnet-ef
    else
        print_info "Entity Framework tools already installed"
    fi
    
    print_success ".NET development environment ready"
}

setup_ruby() {
    print_step "Setting up Ruby development environment"
    
    # Install Ruby dependencies
    install_pacman_packages base-devel openssl zlib readline
    
    # Install Ruby plugin
    install_asdf_plugin "ruby" "https://github.com/asdf-vm/asdf-ruby.git"
    
    # Install Ruby version
    install_language_version "ruby" "3.2.0"
    
    # Install Rails and Bundler
    # Use asdf exec to ensure proper Ruby environment
    if ! asdf exec gem list | grep -q "^rails " 2>/dev/null; then
        print_step "Installing Rails and Bundler"
        asdf exec gem install rails bundler
    else
        print_info "Rails and Bundler already installed"
    fi
    
    print_success "Ruby development environment ready"
}

setup_nodejs() {
    print_step "Setting up Node.js development environment"
    
    # Install Node.js plugin
    install_asdf_plugin "nodejs" "https://github.com/asdf-vm/asdf-nodejs.git"
    
    # Install Node.js LTS
    install_language_version "nodejs" "lts"
    
    # Install global tools using asdf exec
    local tools=("@angular/cli" "create-react-app" "typescript" "yarn")
    for tool in "${tools[@]}"; do
        if ! asdf exec npm list -g "$tool" >/dev/null 2>&1; then
            print_step "Installing global npm package: $tool"
            asdf exec npm install -g "$tool"
        else
            print_info "Global npm package $tool already installed"
        fi
    done
    
    print_success "Node.js development environment ready"
}

setup_docker() {
    print_step "Setting up Docker"
    
    install_pacman_packages docker docker-compose
    
    # Enable Docker service
    if ! systemctl is-enabled docker >/dev/null 2>&1; then
        sudo systemctl enable docker
    fi
    
    if ! systemctl is-active docker >/dev/null 2>&1; then
        sudo systemctl start docker
    fi
    
    # Add user to docker group
    if ! groups | grep -q docker; then
        sudo usermod -aG docker "$USER"
        print_warning "You'll need to log out and back in for Docker group changes to take effect"
    fi
    
    print_success "Docker setup complete"
}

setup_ides() {
    print_step "Setting up IDEs and editors"
    
    local aur_packages=(
        "visual-studio-code-bin"
        "rider"
        "pulsar-bin"
    )
    
    install_aur_packages "${aur_packages[@]}"
    
    # Install spell-check for Pulsar
    install_pacman_packages hunspell-en_gb aspell-en
    
    print_success "IDEs and editors installed"
}

setup_databases() {
    print_step "Setting up database tools (Docker-only approach)"
    
    # Only install SQLite locally
    install_pacman_packages sqlite
    
    # Install database admin tools
    install_pacman_packages pgadmin4
    install_aur_packages dbeaver
    
    print_info "Database setup: SQLite (local), PostgreSQL/MySQL/Redis/MongoDB (Docker containers only)"
    print_success "Database tools installed"
}

setup_development_tools() {
    print_step "Setting up additional development tools"
    
    # Browsers
    install_pacman_packages firefox chromium
    install_aur_packages google-chrome
    
    # API testing and development tools
    install_aur_packages postman-bin insomnia gitkraken
    
    # Command line tools
    install_pacman_packages meld curl httpie vim nano
    
    # Terminal emulators
    install_pacman_packages terminator alacritty kitty tilix
    
    print_success "Development tools installed"
}

setup_gpu_development() {
    print_step "Setting up GPU development tools"
    
    install_aur_packages nvidia-container-toolkit
    
    # Create GPU-accelerated VS Code desktop entry
    print_step "Creating GPU-accelerated VS Code launcher"
    mkdir -p ~/.local/share/applications
    
    if [ ! -f ~/.local/share/applications/code-gpu.desktop ]; then
        cat > ~/.local/share/applications/code-gpu.desktop << 'EOF'
[Desktop Entry]
Name=VS Code (GPU Accelerated)
Comment=Code Editing with GPU
GenericName=Text Editor
Exec=prime-run code --enable-gpu-rasterization %F
Icon=vscode
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=Utility;TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=prime-run code --new-window %F
Icon=vscode
EOF
        print_success "GPU-accelerated VS Code launcher created"
    else
        print_info "GPU-accelerated VS Code launcher already exists"
    fi
    
    # Configure environment for GPU development
    if ! grep -q "NVIDIA_VISIBLE_DEVICES" ~/.zshrc 2>/dev/null; then
        echo 'export NVIDIA_VISIBLE_DEVICES=all' >> ~/.zshrc
    fi
    
    print_success "GPU development environment configured"
}

setup_fonts() {
    print_step "Installing programming fonts"
    
    install_pacman_packages ttf-fira-code ttf-cascadia-code
    install_aur_packages ttf-jetbrains-mono nerd-fonts-complete
    
    print_success "Programming fonts installed"
}

setup_monitoring() {
    print_step "Installing performance monitoring tools"
    
    install_pacman_packages iotop iftop nethogs
    
    print_success "Performance monitoring tools installed"
}

setup_backup_tools() {
    print_step "Installing backup tools"
    
    install_pacman_packages rsync timeshift
    
    print_success "Backup tools installed"
}

configure_git() {
    print_step "Setting up Git configuration"
    
    if ! git config --global user.name >/dev/null 2>&1; then
        read -p "Enter your Git username: " git_username
        read -p "Enter your Git email: " git_email
        git config --global user.name "$git_username"
        git config --global user.email "$git_email"
        print_success "Git configuration set for: $git_username"
    else
        local current_user=$(git config --global user.name)
        print_info "Git already configured for user: $current_user"
    fi
}

# Helper script creation functions
create_asdf_helper() {
    local script_path="$HOME/asdf-helper.sh"
    
    if [ -f "$script_path" ]; then
        print_info "asdf helper script already exists"
        return 0
    fi
    
    print_step "Creating asdf helper script"
    
    cat > "$script_path" << 'EOF'
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
EOF
    
    chmod +x "$script_path"
    print_success "asdf helper script created: $script_path"
}

create_docker_db_helper() {
    local script_path="$HOME/docker-db-helper.sh"
    
    if [ -f "$script_path" ]; then
        print_info "Docker database helper script already exists"
        return 0
    fi
    
    print_step "Creating Docker database helper script"
    
    cat > "$script_path" << 'EOF'
#!/bin/bash

# Docker Database Helper for Development Environment

set -e

print_info() {
    echo -e "\033[1;33m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

case "${1:-help}" in
    "postgres")
        print_info "Starting PostgreSQL container..."
        docker run --name dev-postgres -d \
            -e POSTGRES_PASSWORD=devpassword \
            -e POSTGRES_USER=developer \
            -e POSTGRES_DB=development \
            -p 5432:5432 \
            -v postgres_data:/var/lib/postgresql/data \
            postgres:latest
        print_success "PostgreSQL running on localhost:5432"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 5432"
        echo "  Database: development"
        echo "  Username: developer"
        echo "  Password: devpassword"
        print_info "Connect with: psql -h localhost -U developer -d development"
        print_info "Or use DBeaver/pgAdmin4 with the above credentials"
        ;;
    "mysql")
        print_info "Starting MySQL container..."
        docker run --name dev-mysql -d \
            -e MYSQL_ROOT_PASSWORD=rootpassword \
            -e MYSQL_DATABASE=development \
            -e MYSQL_USER=developer \
            -e MYSQL_PASSWORD=devpassword \
            -p 3306:3306 \
            -v mysql_data:/var/lib/mysql \
            mysql:latest
        print_success "MySQL running on localhost:3306"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 3306"
        echo "  Database: development"
        echo "  Username: developer (or root)"
        echo "  Password: devpassword (root: rootpassword)"
        print_info "Connect with: mysql -h localhost -u developer -p development"
        print_info "Or use DBeaver/MySQL Workbench with the above credentials"
        ;;
    "redis")
        print_info "Starting Redis container..."
        docker run --name dev-redis -d \
            -p 6379:6379 \
            -v redis_data:/data \
            redis:latest redis-server --appendonly yes
        print_success "Redis running on localhost:6379"
        print_info "Connect with: redis-cli -h localhost -p 6379"
        ;;
    "mongo")
        print_info "Starting MongoDB container..."
        docker run --name dev-mongo -d \
            -e MONGO_INITDB_ROOT_USERNAME=developer \
            -e MONGO_INITDB_ROOT_PASSWORD=devpassword \
            -e MONGO_INITDB_DATABASE=development \
            -p 27017:27017 \
            -v mongo_data:/data/db \
            mongo:latest
        print_success "MongoDB running on localhost:27017"
        print_info "Connection details:"
        echo "  Host: localhost"
        echo "  Port: 27017"
        echo "  Database: development"
        echo "  Username: developer"
        echo "  Password: devpassword"
        print_info "Connect with: mongosh mongodb://developer:devpassword@localhost:27017/development"
        ;;
    "status")
        print_info "Database container status:"
        docker ps --filter "name=dev-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    "stop")
        if [ -z "$2" ]; then
            print_info "Stopping all database containers..."
            docker stop $(docker ps -q --filter "name=dev-") 2>/dev/null || print_info "No database containers running"
        else
            print_info "Stopping $2 container..."
            docker stop "dev-$2"
        fi
        ;;
    "remove")
        if [ -z "$2" ]; then
            print_info "Removing all database containers..."
            docker rm $(docker ps -aq --filter "name=dev-") 2>/dev/null || print_info "No database containers to remove"
        else
            print_info "Removing $2 container and data..."
            docker rm "dev-$2"
            docker volume rm "${2}_data" 2>/dev/null || true
        fi
        ;;
    "logs")
        if [ -z "$2" ]; then
            print_error "Please specify database: postgres, mysql, redis, or mongo"
            exit 1
        fi
        docker logs "dev-$2"
        ;;
    "connect")
        case "$2" in
            "postgres")
                docker exec -it dev-postgres psql -U developer -d development
                ;;
            "mysql")
                docker exec -it dev-mysql mysql -u developer -p development
                ;;
            "redis")
                docker exec -it dev-redis redis-cli
                ;;
            "mongo")
                docker exec -it dev-mongo mongosh mongodb://developer:devpassword@localhost:27017/development
                ;;
            *)
                print_error "Please specify database: postgres, mysql, redis, or mongo"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "Docker Database Helper for Development"
        echo "Usage: $0 [command] [options]"
        echo
        echo "Database Commands:"
        echo "  postgres   - Start PostgreSQL container"
        echo "  mysql      - Start MySQL container"
        echo "  redis      - Start Redis container"
        echo "  mongo      - Start MongoDB container"
        echo
        echo "Management Commands:"
        echo "  status     - Show running database containers"
        echo "  stop [db]  - Stop database container(s)"
        echo "  remove [db]- Remove database container(s) and data"
        echo "  logs [db]  - Show database container logs"
        echo "  connect [db] - Connect to database via CLI"
        echo
        echo "Examples:"
        echo "  $0 postgres          # Start PostgreSQL"
        echo "  $0 status            # Show all running databases"
        echo "  $0 stop postgres     # Stop PostgreSQL"
        echo "  $0 connect mysql     # Connect to MySQL CLI"
        echo "  $0 remove            # Remove all database containers"
        echo
        echo "Admin Tools:"
        echo "  DBeaver    - Universal database tool"
        echo "  pgAdmin4   - PostgreSQL administration"
        echo "  Insomnia   - API testing with database connections"
        echo
        echo "All databases use persistent Docker volumes for data storage."
        ;;
esac
EOF
    
    chmod +x "$script_path"
    print_success "Docker database helper script created: $script_path"
}

create_update_script() {
    local script_path="$HOME/update-system.sh"
    
    if [ -f "$script_path" ]; then
        print_info "System update script already exists"
        return 0
    fi
    
    print_step "Creating system update script"
    
    cat > "$script_path" << 'EOF'
#!/bin/bash
echo "Updating system packages..."
sudo pacman -Syu
echo "Updating AUR packages..."
yay -Syu
echo "Updating asdf plugins..."
asdf plugin update --all 2>/dev/null || echo "asdf not available in this session"
echo "Cleaning package cache..."
sudo pacman -Sc
echo "Update complete!"
EOF
    
    chmod +x "$script_path"
    print_success "System update script created: $script_path"
}

add_shell_aliases() {
    print_step "Adding development aliases to zsh"
    
    # Check if aliases already exist
    if grep -q "# Development aliases" ~/.zshrc 2>/dev/null; then
        print_info "Development aliases already added to ~/.zshrc"
        return 0
    fi
    
    cat >> ~/.zshrc << 'EOF'

# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Development shortcuts
alias update-system='sudo pacman -Syu && yay -Syu'
alias clean-packages='sudo pacman -Sc'
alias gpu-test='prime-run glxinfo | grep "OpenGL renderer"'

# asdf shortcuts
alias asdf-versions='asdf list all'
alias asdf-current='asdf current'

# Docker database shortcuts
alias db-postgres='~/docker-db-helper.sh postgres'
alias db-mysql='~/docker-db-helper.sh mysql'
alias db-redis='~/docker-db-helper.sh redis'
alias db-mongo='~/docker-db-helper.sh mongo'
alias db-status='~/docker-db-helper.sh status'
alias db-stop='~/docker-db-helper.sh stop'
EOF
    
    print_success "Development aliases added to ~/.zshrc"
}

# Summary functions
print_completion_summary() {
    print_phase "Setup Complete!"
    
    print_info "Your Dell Precision i9 10th Gen development environment is now set up!"
    echo
    print_info "NEXT STEPS:"
    echo "1. Reboot your system to ensure all services start properly"
    echo "2. Log out and back in to activate Docker group membership"
    echo "3. Run 'source ~/.zshrc' to load new aliases and asdf"
    echo "4. Test GPU switching with: prime-run glxinfo | grep 'OpenGL renderer'"
    echo "5. Create your first system snapshot: sudo timeshift --create --comments 'Complete dev setup'"
    echo
    
    print_info "VERSION MANAGEMENT WITH ASDF:"
    if command_exists asdf; then
        local ruby_version=$(asdf current ruby 2>/dev/null | awk '{print $2}' || echo 'not set')
        local node_version=$(asdf current nodejs 2>/dev/null | awk '{print $2}' || echo 'not set')
        echo "• Ruby $ruby_version installed"
        echo "• Node.js $node_version installed"
    fi
    echo "• Use './asdf-helper.sh' for version management help"
    echo "• Add more languages: asdf plugin add python, asdf plugin add golang, etc."
    echo
    
    print_info "INSTALLED DEVELOPMENT TOOLS:"
    echo "• .NET SDK with Entity Framework"
    echo "• Ruby with Rails via asdf"
    echo "• Node.js with npm, yarn, Angular CLI via asdf"
    echo "• Visual Studio Code with GPU acceleration launcher"
    echo "• JetBrains Rider"
    echo "• Docker with NVIDIA container support"
    echo "• SQLite (local) + Docker containers for PostgreSQL/MySQL/Redis/MongoDB"
    echo "• DBeaver, pgAdmin4 (database admin tools)"
    echo "• Postman, Insomnia (API testing)"
    echo "• Programming fonts and development utilities"
    echo
    
    print_info "Your system is optimized for:"
    echo "• Multi-language development with asdf version management"
    echo "• .NET development with GPU acceleration"
    echo "• Ruby on Rails development"
    echo "• Web development (React, Angular)"
    echo "• Database development"
    echo "• Containerized development with Docker"
    echo
    
    if command_exists nvidia-smi; then
        local driver_version=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits 2>/dev/null || echo "Not available")
        print_info "Graphics setup verified:"
        echo "• NVIDIA T2000 Max-Q drivers: $driver_version"
        echo "• Use 'prime-run <application>' for GPU-intensive tasks"
        echo "• Intel UHD handles desktop for battery efficiency"
        echo
    fi
    
    print_info "DOCKER DATABASE USAGE:"
    echo "• Start databases: db-postgres, db-mysql, db-redis, db-mongo"
    echo "• Check status: db-status"
    echo "• Use './docker-db-helper.sh' for full database management"
    echo "• Connect with DBeaver/pgAdmin4 to localhost with provided credentials"
    echo "• All data persists in Docker volumes"
}
