# Archcraft Setup Guide for Development
*Dell Precision i9 10th Gen Configuration*

## Quick Start

**For automated setup, use the master script:**
```bash
# Clone or navigate to your setup directory
cd ~/workspace/arch-dev-setup

# Run the master setup script (includes all phases below)
./master-dev-setup.sh
```

The master script includes all the manual steps below plus:
- Docker functionality verification after OS restart
- asdf version management with proper error handling
- GPU development optimization
- All helper scripts and aliases
- Complete verification and troubleshooting

---

## Manual Installation Guide

### Phase 1: Archcraft Installation

### Pre-Installation Setup
1. **Download Archcraft ISO**
   - Visit the official Archcraft website and download the latest ISO
   - Create a bootable USB using Rufus (Windows) or `dd` command (Linux)

2. **BIOS/UEFI Configuration**
   - Boot into BIOS/UEFI settings (usually F2 or F12 on Dell)
   - Disable Secure Boot
   - Enable UEFI boot mode
   - Set USB as first boot priority

3. **Boot from USB**
   - Insert USB and restart
   - Select boot from USB device

### Installation Process
1. **Boot Archcraft Live Environment**
   - Select "Boot Archcraft" from the boot menu
   - Wait for the desktop to load

2. **Run Archcraft Installer**
   - Open the Archcraft installer from the desktop or applications menu
   - Follow the installation wizard:
     - Select language and keyboard layout
     - Configure network connection (WiFi or Ethernet)
     - Set timezone and locale

3. **Disk Partitioning**
   - Choose automatic partitioning for simplicity, or manual for custom setup
   - Recommended partition scheme for development:
     - EFI partition: 512MB (if UEFI)
     - Root partition: 50-100GB
     - Home partition: Remaining space
     - Swap: 8-16GB (or equal to RAM for hibernation)

4. **User Account Setup**
   - Create your user account with sudo privileges
   - Set a strong root password

5. **Complete Installation**
   - Review settings and start installation
   - Reboot when prompted and remove USB

## Phase 2: Post-Installation System Setup

### Initial System Update
```bash
# Update system packages
sudo pacman -Syu

# Update AUR helper if installed
yay -Syu
```

### Essential System Tools
```bash
# Install essential development tools
sudo pacman -S base-devel git curl wget vim nano htop neofetch

# Install AUR helper (if not included)
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd .. && rm -rf yay
```

### Graphics Drivers Setup

**First, check what graphics hardware you have:**
```bash
# Check your graphics hardware
lspci | grep -E "(VGA|3D|Display)"

# Check if NVIDIA drivers are already installed
nvidia-smi
pacman -Qs nvidia
```

**Expected output for Dell Precision 10th Gen with T2000 Max-Q:**
- Intel UHD Graphics (integrated) - handles display output
- NVIDIA Quadro T2000 with Max-Q (discrete) - for GPU-intensive tasks

**For Intel Integrated Graphics (UHD 630 - always present):**
```bash
# Install Intel graphics drivers
sudo pacman -S xf86-video-intel intel-media-driver

# Install Vulkan support for Intel
sudo pacman -S vulkan-intel vulkan-icd-loader
```

**For NVIDIA Quadro T2000 Max-Q:**
```bash
# NVIDIA drivers are likely already installed after Archcraft update
# Verify with: nvidia-smi

# If drivers are missing, install them:
sudo pacman -S nvidia nvidia-utils nvidia-settings

# Install nvidia-prime for graphics switching (usually missing)
sudo pacman -S nvidia-prime

# Install NVIDIA Vulkan support
sudo pacman -S vulkan-icd-loader

# Install CUDA support (optional - for .NET ML, data science)
sudo pacman -S cuda cudnn

# Enable NVIDIA services
sudo systemctl enable nvidia-persistenced
```

**Verify Complete Graphics Setup:**
```bash
# Check NVIDIA GPU status
nvidia-smi

# Test graphics switching (after installing nvidia-prime)
prime-run glxinfo | grep "OpenGL renderer"

# Should show Intel for normal use, NVIDIA when using prime-run
```

### Development-Specific GPU Configuration

**Configure VS Code and Rider for GPU Acceleration:**
```bash
# Test GPU switching (after installing nvidia-prime)
prime-run glxinfo | grep "OpenGL renderer"

# VS Code with GPU acceleration
prime-run code --enable-gpu-rasterization --enable-zero-copy

# Create desktop file for GPU-accelerated VS Code
tee ~/.local/share/applications/code-gpu.desktop << 'EOF'
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

# Run JetBrains Rider with GPU acceleration
prime-run rider
```

**GPU Development Tools:**
```bash
# Monitor GPU usage during development
watch -n 1 nvidia-smi

# Configure .NET for GPU acceleration (ML.NET scenarios)
export NVIDIA_VISIBLE_DEVICES=all
echo 'export NVIDIA_VISIBLE_DEVICES=all' >> ~/.bashrc

# Docker with NVIDIA support for development containers
yay -S nvidia-container-toolkit
sudo systemctl restart docker
```

**Power Management for T2000 Max-Q:**
```bash
# Create NVIDIA power management script for development
sudo tee /etc/systemd/system/nvidia-dev-mode.service << 'EOF'
[Unit]
Description=NVIDIA Development Mode
After=graphical.target

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi -pl 80
RemainAfterExit=yes

[Install]
WantedBy=graphical.target
EOF

sudo systemctl enable nvidia-dev-mode
```

### Audio Setup
```bash
# Install PulseAudio or PipeWire
sudo pacman -S pulseaudio pulseaudio-alsa pavucontrol
# OR for PipeWire (more modern)
sudo pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
```

## Phase 3: Development Environment Setup

### .NET Development
```bash
# Install specific .NET SDK version 9.0.203 using Microsoft installer
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 9.0.203

# Configure environment variables
echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.zshrc
echo 'export PATH=$HOME/.dotnet:$PATH:$HOME/.dotnet/tools' >> ~/.zshrc

# Source the updated configuration
source ~/.zshrc

# Verify installation
dotnet --version  # Should show 9.0.203

# Install Entity Framework tools (optional)
dotnet tool install --global dotnet-ef
```

**Note:** This approach installs .NET SDK 9.0.203 to your home directory (`~/.dotnet`), which takes precedence over any system-installed .NET versions. This ensures you get the exact version needed for your development projects.

### Ruby and Rails Development (Using asdf)
```bash
# Install Ruby dependencies
sudo pacman -S base-devel openssl zlib readline

# Add Ruby plugin to asdf
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git

# Install Ruby (latest stable)
asdf install ruby 3.2.0
asdf global ruby 3.2.0

# Install Rails and Bundler
gem install rails bundler

# Note: Node.js will be managed via asdf as well (see below)
```

### Node.js and Web Development (Using asdf)
```bash
# Add Node.js plugin to asdf
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Install Node.js LTS
asdf install nodejs lts
asdf global nodejs lts

# Install global development tools
npm install -g @angular/cli create-react-app typescript yarn

# Install browsers for testing
sudo pacman -S firefox chromium
yay -S google-chrome
```

### Database Systems (Docker-Based Approach)
**Recommended: Use Docker containers for databases to avoid system conflicts**

```bash
# Install only SQLite locally for lightweight development
sudo pacman -S sqlite

# Install database administration tools
sudo pacman -S pgadmin4
yay -S dbeaver

# Use Docker containers for PostgreSQL, MySQL, Redis, MongoDB
# (See Docker Database Helper section below)
```

**Benefits of Docker-based databases:**
- No system service conflicts
- Easy to reset/rebuild databases
- Multiple versions supported
- Persistent data via Docker volumes
- Consistent across development environments

### Docker Database Helper Script

After running the master setup script, you'll have a Docker database helper script:

```bash
# Quick database commands (aliases)
db-postgres    # Start PostgreSQL container
db-mysql       # Start MySQL container
db-redis       # Start Redis container
db-mongo       # Start MongoDB container
db-status      # Show running database containers
db-stop        # Stop all database containers

# Or use the full helper script
./docker-db-helper.sh postgres
./docker-db-helper.sh status
./docker-db-helper.sh connect postgres
```

**Database Connection Details:**
- **PostgreSQL**: localhost:5432, user: developer, password: devpassword, database: development
- **MySQL**: localhost:3306, user: developer (or root), password: devpassword (root: rootpassword), database: development
- **Redis**: localhost:6379 (no authentication)
- **MongoDB**: localhost:27017, user: developer, password: devpassword, database: development

**Connect with Admin Tools:**
- DBeaver: Use connection details above
- pgAdmin4: Configure new server with PostgreSQL details
- MySQL Workbench: Use MySQL connection details

## Phase 4: IDE and Editor Installation

### Visual Studio Code
```bash
# Install VS Code from AUR
yay -S visual-studio-code-bin

# Essential extensions (install via VS Code):
# - C# Dev Kit
# - Ruby LSP
# - Rails
# - HTML/CSS Support
# - JavaScript (ES6) code snippets
# - Prettier
# - GitLens
```

### JetBrains Rider
```bash
# Install Rider
yay -S rider

# Alternative: Install via JetBrains Toolbox
yay -S jetbrains-toolbox
```

### Pulsar (Modern Atom Replacement)
```bash
# Install Pulsar - modern text editor (successor to Atom)
yay -S pulsar-bin

# Install spell-check dictionaries to avoid language errors
sudo pacman -S hunspell-en_gb aspell-en

# Generate British English locale if needed
sudo locale-gen en_GB.UTF-8
```

**Pulsar Spell-Check Configuration:**
If you encounter spell-check errors in Pulsar:
1. The error "The package `spell-check` cannot load the checker for `en_GB`" is fixed by installing dictionaries above
2. Alternative: Change spell-check language in Pulsar Settings from `en_GB` to `en_US` or `en`
3. Or temporarily disable spell-check if not needed

**Pulsar Benefits for Development:**
- Modern successor to Atom with active development
- Extensive package ecosystem
- Git integration
- Multiple cursors and advanced editing features
- Customizable interface and themes
- Good performance improvements over original Atom

## Phase 5: Terminal Applications

### Warp Terminal
```bash
# Install Warp Terminal
yay -S warp-terminal
```

### Terminator
```bash
# Install Terminator
sudo pacman -S terminator
```

### Additional Terminal Options
```bash
# Alacritty (GPU-accelerated)
sudo pacman -S alacritty

# Kitty (GPU-accelerated with advanced features)
sudo pacman -S kitty

# Tilix (advanced terminal emulator)
sudo pacman -S tilix
```

## Phase 6: Development Utilities and Tools

### asdf Version Management

The master setup script installs asdf for managing multiple programming language versions:

```bash
# asdf helper script (created by master setup)
./asdf-helper.sh status        # Show current versions
./asdf-helper.sh ruby          # Ruby version management
./asdf-helper.sh node          # Node.js version management
./asdf-helper.sh python        # Install Python plugin
./asdf-helper.sh add-plugin go # Add new language plugins
```

**Common asdf commands:**
```bash
# List all available versions
asdf list all ruby
asdf list all nodejs

# Install specific versions
asdf install ruby 3.2.0
asdf install nodejs 18.19.0

# Set global versions
asdf global ruby 3.2.0
asdf global nodejs lts

# Set project-specific versions (creates .tool-versions file)
asdf local ruby 3.1.0
asdf local nodejs 16.20.0

# Show current versions
asdf current
```

### SSH Setup for GitHub

To use SSH with GitHub, follow these steps:

```bash
# 1. Generate an SSH key pair
ssh-keygen -t ed25519 -C "trevor@archcraft-dev" -f ~/.ssh/github_ed25519

# 2. Start the SSH agent
eval "$(ssh-agent -s)"

# 3. Add your SSH private key to the agent
ssh-add ~/.ssh/github_ed25519

# 4. Copy your public key
cat ~/.ssh/github_ed25519.pub

# 5. Add the public key to GitHub
# Visit: https://github.com/settings/keys and add a new SSH key

# 6. Create SSH config for GitHub
mkdir -p ~/.ssh
cat  /.ssh/config  'EOF'
# GitHub configuration
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/github_ed25519
  AddKeysToAgent yes
EOF

# Ensure correct permissions
chmod 600 ~/.ssh/config

# 7. Test the SSH connection to GitHub
ssh -T git@github.com
```

You will see a message confirming successful authentication.

### Version Control
```bash
# Git configuration
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Install Git GUI tools
sudo pacman -S gitg
yay -S gitkraken
```

### Docker and Containerization
```bash
# Install Docker
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Install NVIDIA container support for GPU development
yay -S nvidia-container-toolkit

# Note: You'll need to logout/login or reboot for group changes to take effect
```

**Verify Docker Installation:**
```bash
# Check Docker status
docker --version
docker info

# Test with hello-world container
docker run --rm hello-world

# If Docker commands fail with permission errors:
# 1. Ensure you're in the docker group: groups | grep docker
# 2. If not, logout and login again, or reboot
# 3. Restart Docker service: sudo systemctl restart docker
```

### Additional Development Tools
```bash
# API testing
yay -S postman-bin insomnia

# Database management
yay -S dbeaver
sudo pacman -S pgadmin4

# File comparison
sudo pacman -S meld

# REST client
sudo pacman -S curl httpie

# Text editors and note-taking
sudo pacman -S vim nano
yay -S pulsar-bin  # Modern Atom replacement

# Install spell-check dictionaries for Pulsar
sudo pacman -S hunspell-en_gb aspell-en
```

## Phase 7: System Optimization for Development

### Performance Tuning
```bash
# Install performance monitoring tools
sudo pacman -S iotop iftop nethogs

# Configure swappiness for better performance
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf

# Install TLP for advanced power management
sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp.service
sudo systemctl start tlp.service

# Disable conflicting power management services
sudo systemctl disable power-profiles-daemon
sudo systemctl stop power-profiles-daemon
```

### CPU Scaling Governors and Power Management

**Available CPU Scaling Governors:**

- **`performance`** - Always runs at maximum frequency (best for development, highest power usage)
- **`powersave`** - Always runs at minimum frequency (best for battery life, lowest power usage)
- **`ondemand`** - Dynamically scales frequency based on load (balanced performance/power)
- **`conservative`** - Similar to ondemand but more gradual frequency changes (smoother transitions)
- **`schedutil`** - Modern governor using scheduler information (default on newer kernels, adaptive)
- **`userspace`** - Allows manual frequency control by userspace programs

**Check available governors on your system:**
```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
```

**Configure TLP for development workstation:**
```bash
# Edit TLP configuration
sudo nano /etc/tlp.conf

# Recommended settings for development:
# High performance when plugged in
CPU_SCALING_GOVERNOR_ON_AC=performance

# Power saving on battery
CPU_SCALING_GOVERNOR_ON_BAT=powersave

# Alternative balanced approach:
# CPU_SCALING_GOVERNOR_ON_AC=ondemand
# CPU_SCALING_GOVERNOR_ON_BAT=conservative

# Apply TLP configuration
sudo systemctl restart tlp.service
sudo tlp start
```

**TLP Management and Troubleshooting:**
```bash
# Apply TLP settings after configuration changes
sudo systemctl restart tlp.service
sudo tlp start

# Check TLP status and current settings
sudo tlp-stat -s

# Verify CPU governor status
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
cpupower frequency-info

# Force apply AC/Battery mode
sudo tlp ac    # Force AC mode
sudo tlp bat   # Force battery mode

# Check TLP configuration syntax
sudo tlp-stat -c

# Monitor TLP service status
systemctl status tlp
```

### CPU Performance Management (Intel 10th Gen)
```bash
# Create CPU performance limit service for development workloads
sudo tee /etc/systemd/system/cpu-limit.service << 'EOF'
[Unit]
Description=CPU Performance Limit
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'echo 95 > /sys/devices/system/cpu/intel_pstate/max_perf_pct'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl enable cpu-limit.service
sudo systemctl start cpu-limit.service

# Verify CPU performance setting
cat /sys/devices/system/cpu/intel_pstate/max_perf_pct
```

### Updating CPU Performance Settings
```bash
# To modify the CPU performance limit later:

# 1. Edit the service file
sudo nano /etc/systemd/system/cpu-limit.service

# 2. Change the value (e.g., from 80 to 95):
# ExecStart=/bin/bash -c 'echo 95 > /sys/devices/system/cpu/intel_pstate/max_perf_pct'

# 3. Reload and restart the service
sudo systemctl daemon-reload
sudo systemctl restart cpu-limit.service

# 4. Verify the change
cat /sys/devices/system/cpu/intel_pstate/max_perf_pct

# Alternative: Apply change immediately without service restart
echo 95 | sudo tee /sys/devices/system/cpu/intel_pstate/max_perf_pct

# Check service status
sudo systemctl status cpu-limit.service
```

**Note:** Use either the Intel P-State service above OR TLP power management, not both simultaneously to avoid conflicts.

### Shell Configuration
```bash
# Install Zsh with Oh My Zsh (optional)
sudo pacman -S zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Or configure Bash with useful aliases
cat >> ~/.bashrc << 'EOF'
# Development aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
EOF
```

### Font Installation for Development
```bash
# Install programming fonts
sudo pacman -S ttf-fira-code ttf-cascadia-code
yay -S ttf-jetbrains-mono

# Install Nerd Fonts for terminal icons
yay -S nerd-fonts-complete
```

## Phase 8: Backup and Maintenance

### System Backup Setup
```bash
# Install backup tools
sudo pacman -S rsync timeshift

# Create system snapshot
sudo timeshift --create --comments "Fresh development setup"
```

### Maintenance Scripts
```bash
# Create update script
cat > ~/update-system.sh << 'EOF'
#!/bin/bash
echo "Updating system packages..."
sudo pacman -Syu
echo "Updating AUR packages..."
yay -Syu
echo "Cleaning package cache..."
sudo pacman -Sc
echo "Update complete!"
EOF
chmod +x ~/update-system.sh
```

### Package Management Tips
```bash
# List explicitly installed packages
pacman -Qe

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Clean package cache
sudo pacman -Sc
```

## Troubleshooting Common Issues

### WiFi Issues
```bash
# Install additional WiFi drivers if needed
sudo pacman -S linux-firmware
yay -S rtl88xxau-aircrack-dkms-git  # For Realtek adapters
```

### Audio Issues
```bash
# Restart audio service
systemctl --user restart pulseaudio
# or for PipeWire
systemctl --user restart pipewire
```

### Graphics Issues
```bash
# Check graphics driver status
lspci -k | grep -A 2 -E "(VGA|3D)"
glxinfo | grep "OpenGL renderer"
```

## Notes for Dell Precision i9 10th Gen with T2000 Max-Q

**Graphics Setup Summary:**
- Your NVIDIA drivers are likely already installed after Archcraft system update
- You primarily need to install `nvidia-prime` for graphics switching
- Intel UHD Graphics handles desktop and basic tasks for battery efficiency
- NVIDIA T2000 Max-Q automatically activates for GPU-intensive development tasks
- Use `prime-run` command to explicitly use NVIDIA GPU for specific applications

**Expected nvidia-smi output:**
```
NVIDIA Quadro T2000 with Max-Q Design
Driver Version: 575.64 or newer
CUDA Version: 12.9 or newer
Memory: 4096 MiB GDDR6
```

## Final Notes

- Keep your system updated regularly with `sudo pacman -Syu`
- Consider using virtual environments for different projects (Python venv, Node nvm, Ruby rbenv)
- Configure your firewall: `sudo ufw enable`
- Set up automatic backups of your home directory
- Join the Arch Linux community forums for support
- Your T2000 Max-Q provides excellent performance for development while maintaining good battery life
- The hybrid graphics setup automatically optimizes between Intel (efficiency) and NVIDIA (performance)

Remember to reboot after major installations and driver updates!

## Quick Reference - Helper Scripts

After running the master setup script, you'll have these helpful tools:

### System Management
```bash
./update-system.sh          # Update system packages, AUR, asdf plugins, clean Docker
./master-dev-setup.sh        # Re-run master setup (safe to run multiple times)
```

### Version Management (asdf)
```bash
./asdf-helper.sh status      # Show installed language versions
./asdf-helper.sh ruby        # Ruby version management help
./asdf-helper.sh node        # Node.js version management help
./asdf-helper.sh python      # Install Python plugin and show help
```

### Database Management (Docker)
```bash
./docker-db-helper.sh postgres   # Start PostgreSQL development database
./docker-db-helper.sh status     # Show running database containers
./docker-db-helper.sh stop       # Stop all database containers
./docker-db-helper.sh connect postgres  # Connect to PostgreSQL CLI

# Quick aliases (after sourcing ~/.zshrc)
db-postgres, db-mysql, db-redis, db-mongo  # Start databases
db-status                                   # Check database status
db-stop                                     # Stop all databases
```

### GPU Development
```bash
prime-run code               # VS Code with GPU acceleration
prime-run glxinfo | grep "OpenGL renderer"  # Test GPU switching
nvidia-smi                   # Monitor GPU usage
```

### Development Shortcuts (after sourcing ~/.zshrc)
```bash
# System shortcuts
update-system               # Update all packages
clean-packages              # Clean package cache
gpu-test                    # Test GPU switching

# Git shortcuts
gs                          # git status
ga                          # git add
gc                          # git commit
gp                          # git push
gl                          # git log --oneline

# asdf shortcuts
asdf-versions               # List all available versions
asdf-current                # Show current versions
```

## Post-Setup Verification

**After running the master setup script, verify your installation:**

```bash
# Test Docker
docker run --rm hello-world

# Test asdf
asdf current

# Test databases
db-postgres
db-status
db-stop

# Test GPU switching (if NVIDIA present)
prime-run glxinfo | grep "OpenGL renderer"

# Test development tools
dotnet --version
ruby --version
node --version
code --version
```

**Troubleshooting:**
- If Docker permission denied: logout/login or reboot
- If asdf not found: `source ~/.zshrc`
- If database connection fails: check `docker ps` for running containers
- If GPU switching fails: ensure nvidia-prime is installed
