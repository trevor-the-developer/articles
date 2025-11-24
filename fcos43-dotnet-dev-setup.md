# Bazzite (Fedora Core 43 based) Linux
## .NET Developer Environment Setup Guide

This guide will detail how to get a working .NET development environment up and running in Fedora Core 43 based Linux Distro's such as Bazzite (used for this guide).

### Prequisites

Ensure your Bazzite distro is updated:
```bash
ujust update
```

### .NET SDK installations

The following link details steps to download the .NET SDK installation script and setup the relevant SDK's (these include the .NET and aspnet runtimes):

[Scripted Install](https://learn.microsoft.com/en-us/dotnet/core/install/linux-scripted-manual#scripted-install)

#### Script installation steps

Download the dotnet installation script (~/Downloads is a good location):
```bash
wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
```

Now make the file executable:
```bash
chmod +x dotnet-install.sh
```

Finally run the script to install your desired SDK's (for this guide I selected .NET 10, 9.0 and 8.0):
```bash
# .NET 10
./dotnet-install.sh --version latest

# .NET 9.0
./dotnet-install.sh --channel 9.0

# .NET 8.0
./dotnet-install.sh --channel 8.0
```

#### Environment setup
We need to setup a symlink to ensure dotnet is available system wide:
```bash
sudo ln -s ~/.dotnet/dotnet /usr/local/bin/dotnet
```

#### Test the installation
```bash
dotnet --list-sdks
dotnet --list-runtimes
dotnet --version
```

You should see the SDK's listed and the version 10.0.100.   You can set a different SDK globally using the following command:
```bash
dotnet new globaljson --sdk-version 9.0.308
```
Replacing the version number for the SDK you prefer (see dotnet --list-sdks command earlier)

#### Useful commands
If you have multiple SDK's you can create a new project using a specific SDK:
```bash
dotnet new console --framework net8.0
```

### JetBrains Toolbox & Rider Installation

Download the JetBrains Toolbox archive from the [JetBrains website](https://www.jetbrains.com/toolbox-app/download/download-thanks.html?platform=linux).

Now extract the archive (I prefer to have an Applications folder in the home directory for such tools):
```bash
mkdir -p ~/Applications/JetBrains-Toolbox
```

Next extract the archive to this folder:
```bash
# change directory to the ~/Downloads folder if you are not already in there
# now extract the archive (your version number may be newer than this guide)
tar xvf jetbrains-toolbox-3.1.0.62320.tar.gz -C ~/Applications/JetBrains-Toolbox
```

Navigate to the ~/Applications/JetBrains-Toolbox folder and execute the JetBrains toolbox app:
```bash
./bin/jetbrains-toolbox
```
This will initialize various Toolbox application files in the application directory:
`~/.local/share/JetBrains/Toolbox`

Upon the first launch, JetBrains Toolbox App will also create a
`.desktop entry file in ~/.local/share/applications`

#### Rider first run
Launch Rider from the Gnome Launcher or type `rider` in a terminal to start the application.

Create a new project or open an existing .NET project and then go to the Settings screen (*gear icon on top right or left-click the burger icon top left from the File menu select Settings or Ctrl+Alt+S keys to display the settings screen*).

If you need to adjust the UI font scaling left-click on **Appearance & Behaviour** and select **Appearance** then set the Zoom to 125% or greater for your needs.

Next select **Build, Execution, Deployment** form the left hand column and then **Toolset and Build** sub-item to display the build settings.  The MSBuild version should be auto selected to .NET SDK 10 this is fine unless you need a specific version then browse to the correct version by left-clicking on the Custom.. button and browsing to the correct SDK verison folder and selecting the MSBuild.dll file.

Press the Save button at the bottom right if you have made any changes and exit the settings screen.

### Podman and podman-compose
Podman is installed by default however podman-compose offers similar features to docker-compose and this needs to be layered onto the base system using `rpm-ostree`:
```bash
rpm-ostree install podman-compose
```

The changes will be queued and applied on the next reboot (*if its safe to do so type `reboot` in the terminal to do this*).

When you have logged back in you can test both podman and podman-compose to confirm operation:
```bash
podman-compose version
```
This will output similar to:
```bash
podman-compose version 1.5.0
podman version 5.6.2
```

#### Alias docker to podman
We need to ensure docker commands are properly mapped to podman.

The following command ensure the mapping is persistent:
```bash
# Persistent system-wide symlinks
sudo mkdir -p /usr/local/bin
sudo ln -sf /usr/bin/podman /usr/local/bin/docker
sudo ln -sf /usr/bin/podman-compose /usr/local/bin/docker-compose

# Persistent user aliases (as backup)
echo 'alias docker="podman"' >> ~/.bashrc
echo 'alias docker-compose="podman-compose"' >> ~/.bashrc
source ~/.bashrc
```

#### Test the setup
```bash
# Test basic commands
docker --version
docker ps
docker-compose --version

# These should show Podman versions, not Docker
```

### dotnet-ef tool
Rider will prompt you to install dotnet-ef if it detects a project with EF Core or you can issue the following command to do this:
```bash
dotnet tool install --global dotnet-ef
```

#### Fix the dotnet-ef path and root issues
```bash
# Add .NET tools to PATH permanently
echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bashrc

# Set DOTNET_ROOT to point to your .NET installation
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.bashrc

# Also add to ~/.bash_profile for login shells
echo 'export PATH="$PATH:$HOME/.dotnet/tools"' >> ~/.bash_profile
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.bash_profile

# Apply to current session
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT="$HOME/.dotnet"

# reload the shell
source ~/.bashrc
```

#### Test the fix
```bash

# Check if dotnet-ef works now
dotnet-ef --version

# Verify PATH includes tools directory
echo $PATH

# Verify DOTNET_ROOT is set
echo $DOTNET_ROOT
```

This should output similar:
```bash
# Check if dotnet-ef works now
dotnet-ef --version

# Verify PATH includes tools directory
echo $PATH

# Verify DOTNET_ROOT is set
echo $DOTNET_ROOT
Entity Framework Core .NET Command-line Tools
10.0.0
/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:/home/trevor/.local/bin:/home/trevor/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/home/trevor/.dotnet/tools:/home/trevor/.local/share/JetBrains/Toolbox/scripts:/home/trevor/.dotnet/tools:/home/trevor/.dotnet/tools:/home/trevor/.dotnet/tools
/home/trevor/.dotnet
```

## Optional AWS-CLI
If you use any of the S3 type containers (*Garage, Minio etc*) then you need to create a distrobox container to install AWS-CLI as Fedora Core 43 is an immutable system and commands like `sudo dnf` do not work on the host only inside distrobox containers.

### Create the container and setup AWS-CLI

First we need to create a Fedora Core 43 container:
```bash
distrobox create --name aws-tools --image quay.io/fedora/fedora:43
```
Enter the container to perform the initial setup:
```bash
distrobox enter aws-tools
```
Once the setup is complete install nano editor:
```bash
sudo dnf install nano
```
We need to modify the sudoers file to ensure the container user has elevated privileges:
```bash
sudo visudo
```
Page-down key to get to the end locate the line:
```bash
root    ALL=(ALL)       ALL
```
add the following line below:
```bash
your-username    ALL=(ALL)       ALL
```
Where `your-username` is the user logged into the container - finally press `Ctrl o` key to write the changes and then `Ctrl x` key to exit.

#### Install AWS-CLI v2
```bash
sudo dnf install -y awscli2
```

Map the AWS config directories:
```bash
ln -s /home/your-username/.aws ~/.aws
```

Modify the host .bashrc add an alias to make it easy to use the command on the host:
```bash
# add this on a new line at the end:
alias awscli='distrobox-enter aws-tools -- aws'
```

Reload the shell `source ~/.bashrc` and test with `awscli s3 ls` this should show the Garage S3 bucket if one was setup - see the [guide](https://garagehq.deuxfleurs.fr/documentation/quick-start/).

## Conclusion

This completes the .NET development environment on a Fedora Core 43 based Linux Distro such as Bazzite, feel free to add your own apps and perform any setup as required however do note:
- use a distrobox container (name it `dev-tools`) to install developer tools (`sudo dnf group install development-tools`)
- flatpak applications may not have access to the host files Rider is one example
- don't clutter the base image (using `rpm-ostree`) with apps and tools unless necessary
- apps installed inside a distrobox container are available to the Gnome desktop and the host
