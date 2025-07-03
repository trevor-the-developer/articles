# JetBrains Toolbox Installation Guide

## Overview
This guide walks through installing JetBrains Toolbox from a tarball on Linux systems. JetBrains Toolbox is a desktop application that helps you install, update, and manage JetBrains IDEs like IntelliJ IDEA, PyCharm, WebStorm, and more.

## Prerequisites
- Linux system with sudo privileges
- Downloaded JetBrains Toolbox tarball (e.g., `jetbrains-toolbox-2.6.3.43718.tar.gz`)
- Terminal access

## Installation Steps

### 1. Extract the Tarball
Navigate to the directory containing the tarball and extract it:

```bash
cd ~/Downloads
tar -xzf jetbrains-toolbox-2.6.3.43718.tar.gz
```

### 2. Verify Extraction
Check that the files were extracted correctly:

```bash
ls -la jetbrains-toolbox-2.6.3.43718/
ls -la jetbrains-toolbox-2.6.3.43718/bin/
```

You should see the main executable `jetbrains-toolbox` and other necessary files.

### 3. Move to System Directory
Move the extracted directory to `/opt` for system-wide installation:

```bash
sudo mv jetbrains-toolbox-2.6.3.43718 /opt/jetbrains-toolbox
```

### 4. Create Symbolic Link
Create a symbolic link in `/usr/local/bin` for easy command-line access:

```bash
sudo ln -sf /opt/jetbrains-toolbox/bin/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox
```

### 5. Install Desktop Entry
Copy the desktop file to make it available in your application menu:

```bash
sudo cp /opt/jetbrains-toolbox/bin/jetbrains-toolbox.desktop /usr/share/applications/
```

### 6. Update Desktop File Path
Update the desktop file to point to the correct executable location:

```bash
sudo sed -i 's|Exec=.*|Exec=/opt/jetbrains-toolbox/bin/jetbrains-toolbox|' /usr/share/applications/jetbrains-toolbox.desktop
```

### 7. Verify Installation
Check that the installation was successful:

```bash
which jetbrains-toolbox
```

This should return `/usr/local/bin/jetbrains-toolbox`.

## Usage

### Launch Methods
You can now launch JetBrains Toolbox in several ways:

1. **From Terminal:**
   ```bash
   jetbrains-toolbox
   ```

2. **From Application Menu:**
   Look for "JetBrains Toolbox" in your desktop environment's application menu

3. **Direct Execution:**
   ```bash
   /opt/jetbrains-toolbox/bin/jetbrains-toolbox
   ```

### First Run
When you first launch JetBrains Toolbox:
1. It will create a configuration directory in your home folder
2. You may need to accept the license agreement
3. The toolbox will appear in your system tray
4. You can then install JetBrains IDEs through the interface

## File Structure
After installation, the files are organized as follows:

```
/opt/jetbrains-toolbox/
├── bin/
│   ├── jetbrains-toolbox          # Main executable
│   ├── jetbrains-toolbox.desktop  # Desktop entry
│   ├── askpass                    # Password helper
│   ├── jre/                       # Java Runtime Environment
│   ├── lib/                       # Library files
│   └── ...                        # Other support files
/usr/local/bin/
├── jetbrains-toolbox              # Symbolic link
/usr/share/applications/
├── jetbrains-toolbox.desktop      # System desktop entry
```

## Troubleshooting

### Common Issues

1. **Permission Denied:**
   - Ensure you have sudo privileges
   - Check that the executable has proper permissions: `chmod +x /opt/jetbrains-toolbox/bin/jetbrains-toolbox`

2. **Desktop Entry Not Appearing:**
   - Refresh your desktop environment's application cache
   - Log out and log back in
   - Check if the desktop file exists: `ls -la /usr/share/applications/jetbrains-toolbox.desktop`

3. **Command Not Found:**
   - Verify the symbolic link exists: `ls -la /usr/local/bin/jetbrains-toolbox`
   - Check if `/usr/local/bin` is in your PATH: `echo $PATH`

### Uninstallation
To remove JetBrains Toolbox:

```bash
# Remove the application directory
sudo rm -rf /opt/jetbrains-toolbox

# Remove the symbolic link
sudo rm /usr/local/bin/jetbrains-toolbox

# Remove the desktop entry
sudo rm /usr/share/applications/jetbrains-toolbox.desktop

# Remove user configuration (optional)
rm -rf ~/.local/share/JetBrains/Toolbox
```

## Additional Notes

- **System Requirements:** JetBrains Toolbox requires a 64-bit Linux system
- **Updates:** The toolbox will automatically check for and install updates
- **IDE Management:** Use the toolbox to install, update, and manage multiple versions of JetBrains IDEs
- **License:** Each IDE may require its own license or subscription

## Tested Environment
- **OS:** Archcraft Linux
- **Shell:** zsh 5.9
- **Version:** JetBrains Toolbox 2.6.3.43718

---

*This guide was created on July 3, 2025. For the latest information, visit the [JetBrains Toolbox official page](https://www.jetbrains.com/toolbox-app/).*
