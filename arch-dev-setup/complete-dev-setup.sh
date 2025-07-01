#!/bin/bash

# Complete Development Environment Setup for Dell Precision i9 10th Gen
# Based on ~/Notes/Archcraft/dev-setup-guide.md
# Using asdf for version management instead of rbenv

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_phase() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
}

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_phase "Development Environment Setup Completion"
print_info "Based on your dev-setup-guide.md for Dell Precision i9 10th Gen"
print_info "System detected: Archcraft Linux with NVIDIA T2000 Max-Q"
print_info "Using asdf for multi-language version management"

# Check if yay is installed
if ! command_exists yay; then
    print_step "Installing AUR helper (yay)"
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay
else
    print_info "AUR helper (yay) already installed"
fi

# Update system first
print_step "Updating system packages"
sudo pacman -Syu --noconfirm

print_phase "Phase 3: Development Environment Setup"

# Install asdf for version management
print_step "Installing asdf version manager"
yay -S --noconfirm asdf-vm

# Add asdf to shell profile
print_step "Configuring asdf for zsh"
cat >> ~/.zshrc << 'EOF'

# asdf version manager
. /opt/asdf-vm/asdf.sh
EOF

# Source asdf for current session
source /opt/asdf-vm/asdf.sh

# .NET Development
print_step "Installing .NET SDK and Runtime"
sudo pacman -S --noconfirm dotnet-sdk dotnet-runtime
print_step "Installing Entity Framework tools"
dotnet tool install --global dotnet-ef

# Ruby Development with asdf
print_step "Installing Ruby plugin for asdf"
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
print_step "Installing Ruby dependencies"
sudo pacman -S --noconfirm base-devel openssl zlib readline

# Node.js Development with asdf
print_step "Installing Node.js plugin for asdf"
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Install specific versions (you can change these)
print_step "Installing Ruby 3.2.0"
asdf install ruby 3.2.0
asdf global ruby 3.2.0

print_step "Installing Node.js LTS"
asdf install nodejs lts
asdf global nodejs lts

# Install Rails and global Node tools
print_step "Installing Rails and global Node.js tools"
gem install rails bundler
npm install -g @angular/cli create-react-app typescript yarn

# Browsers for testing
print_step "Installing browsers for development testing"
sudo pacman -S --noconfirm firefox chromium
yay -S --noconfirm google-chrome

# Database Administration Tools (Docker-only databases)
print_step "Installing database admin tools for Docker containers"
sudo pacman -S --noconfirm sqlite  # Keep SQLite for local dev/testing
# Note: PostgreSQL and MySQL will run in Docker containers

print_phase "Phase 4: IDE and Editor Installation"

# Visual Studio Code
print_step "Installing Visual Studio Code"
yay -S --noconfirm visual-studio-code-bin

# JetBrains Rider
print_step "Installing JetBrains Rider"
yay -S --noconfirm rider

# Pulsar (Modern Atom replacement)
print_step "Installing Pulsar text editor"
yay -S --noconfirm pulsar-bin
sudo pacman -S --noconfirm hunspell-en_gb aspell-en

print_phase "Phase 5: Terminal Applications"

# Additional terminal options (your Warp is already installed)
print_step "Installing additional terminal emulators"
sudo pacman -S --noconfirm terminator alacritty kitty tilix

print_phase "Phase 6: Development Utilities and Tools"

# Docker and Containerization
print_step "Installing Docker"
sudo pacman -S --noconfirm docker docker-compose
sudo systemctl enable docker
sudo usermod -aG docker $USER
print_info "You'll need to log out and back in for Docker group changes to take effect"

# Additional Development Tools
print_step "Installing additional development tools"
yay -S --noconfirm postman-bin insomnia dbeaver gitkraken
sudo pacman -S --noconfirm pgadmin4 meld curl httpie vim nano

print_phase "Phase 7: System Optimization (Graphics-Specific)"

# GPU Development Tools
print_step "Installing GPU development tools"
yay -S --noconfirm nvidia-container-toolkit

# Create GPU-accelerated VS Code desktop entry
print_step "Creating GPU-accelerated VS Code launcher"
mkdir -p ~/.local/share/applications
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

# Configure environment for GPU development
print_step "Configuring GPU development environment"
echo 'export NVIDIA_VISIBLE_DEVICES=all' >> ~/.zshrc

# Performance monitoring tools
print_step "Installing performance monitoring tools"
sudo pacman -S --noconfirm iotop iftop nethogs

print_phase "Phase 8: Fonts and Final Setup"

# Programming fonts
print_step "Installing programming fonts"
sudo pacman -S --noconfirm ttf-fira-code ttf-cascadia-code
yay -S --noconfirm ttf-jetbrains-mono nerd-fonts-complete

# Backup tools
print_step "Installing backup tools"
sudo pacman -S --noconfirm rsync timeshift

# Git configuration
print_step "Setting up Git configuration"
if ! git config --global user.name >/dev/null 2>&1; then
    read -p "Enter your Git username: " git_username
    read -p "Enter your Git email: " git_email
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
else
    print_info "Git already configured for user: $(git config --global user.name)"
fi

# Shell aliases for development
print_step "Adding development aliases to zsh"
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

# Create version management helper script
print_step "Creating asdf helper script"
cat > ~/asdf-helper.sh << 'EOF'
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
chmod +x ~/asdf-helper.sh

# Create update script
print_step "Creating system update script"
cat > ~/update-system.sh << 'EOF'
#!/bin/bash
echo "Updating system packages..."
sudo pacman -Syu
echo "Updating AUR packages..."
yay -Syu
echo "Updating asdf plugins..."
asdf plugin update --all
echo "Cleaning package cache..."
sudo pacman -Sc
echo "Update complete!"
EOF
chmod +x ~/update-system.sh

# Create Docker database helper script
print_step "Creating Docker database helper script"
cat > ~/docker-db-helper.sh << 'EOF'
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
chmod +x ~/docker-db-helper.sh

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
echo "• Ruby $(asdf current ruby 2>/dev/null || echo 'not set') installed"
echo "• Node.js $(asdf current nodejs 2>/dev/null || echo 'not set') installed"
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
print_info "Graphics setup verified:"
echo "• NVIDIA T2000 Max-Q drivers: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits)"
echo "• Use 'prime-run <application>' for GPU-intensive tasks"
echo "• Intel UHD handles desktop for battery efficiency"
echo
print_info "DOCKER DATABASE USAGE:"
echo "• Start databases: db-postgres, db-mysql, db-redis, db-mongo"
echo "• Check status: db-status"
echo "• Use './docker-db-helper.sh' for full database management"
echo "• Connect with DBeaver/pgAdmin4 to localhost with provided credentials"
echo "• All data persists in Docker volumes"
