# Bazzite (Fedora Core 43 based) Linux
## VS Code Distrobox Setup

You can access the host's .NET SDK from inside a Distrobox container, this guide will detail how to get VS Code setup inside a Distrobox container with .NET SDK support related development tools and libraries.

### Prequisites

Ensure your Bazzite distro is updated:
```bash
ujust update
```

### Create the Distrobox container (Fedore Core 43 based) and setup the environment

From the host terminal create the Distrobox container:
```bash
distrobox create --name dev-apps --image quay.io/fedora/fedora:43 --additional-flags "--volume $HOME/.dotnet:/home/$USER/.dotnet"

# TEMP ALT:
# distrobox create --name dev-apps --image quay.io/fedora/fedora:43 --additional-flags "--volume $HOME/.dotnet:/home/$USER/.dotnet"

```
Enter the container to finish the setup:
```bash
distrobox enter dev-apps
```

#### Add user to sudoers file

Once the setup is complete install nano editor:
```bash
sudo dnf install -y nano
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

#### Install useful development tools

The following tools and libraries are useful and will avoid any future errors:
```bash
# install development-tools
sudo dnf group install -y development-tools

# install ICU library (.NET requires ICU libraries for globalisation)
sudo dnf install -y icu
```

#### Environment variables

Run the following commands from inside the Distrobox container (`dev-apps`):
```bash
# Add to PATH and set DOTNET_ROOT
echo 'export DOTNET_ROOT="$HOME/.dotnet"' >> ~/.bashrc
echo 'export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"' >> ~/.bashrc
```
Reload the shell:
```bash
source ~/.bashrc
```
Finally test the dotnet command:
```bash
dotnet --version
```

#### Verify the complete setup:
```bash
# Inside distrobox:
echo $DOTNET_ROOT
echo $PATH
which dotnet
dotnet --version
dotnet --list-sdks
dotnet-ef --version
```

### VS Code installation

VS Code needs to be installed inside the Distrobox container created above (`dev-apps`) taking advantage of the .NET SDK setup and the container environment.

The following guide details the steps to install VS Code on various flavours of Linux and the Fedora Core 43 specific steps are detailed below.

#### Import the repository and install VS Code

Microsoft currently ship the stable 64-bit VS Code for RHEL, Fedora, or CentOS based distributions in a yum repository.   The following command imports the repository to the container environment:
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
```

Next update the package cache and then perform the VS Code installation:
```bash
dnf check-update
sudo dnf install code # or code-insiders (the nightly build)
```

```bash
# Export VS Code to your host applications
distrobox-export --app code
```

This will create a launcher in your host's application menu (Gnome launcher on Bazzite).

### Finalising the setup

Start VS Code by launching from the Gnome Launcher or typing `code` inside the Distrobox container.   Once VS Code has started left-click on the Extensions icon in the left-hand column (or press `Ctrl+Shift+x`) to display the Extensions panel and then type `C#` in the search box to filter the list.

The first item should be `C# Dev Kit` select this and left-click on the **Install** button to begin the installation.   This extension also installs several other extensions like C# base language support giving a rich user experience for .NET developers in VS Code (*you will get prompted to sign into the Visual Studio subscription you can do this now if you have it*).

#### Make VS Code accessible from the host terminal

Modify the host .bashrc add an alias to make it easy to use the command on the host:
```bash
# add this on a new line at the end:
alias vscode='distrobox-enter dev-apps -- code .
```

Reload the shell source ~/.bashrc and test with `vscode` in your project folder (*this should load VS Code and open the project folder you execute the command from*).

### Summary

We now have a fully functional development environment where:

- Host system: Has .NET SDKs, Rider, Podman/Docker, AWS CLI access
- Distrobox containers: Can access host's .NET installation seamlessly
- Everything persists across reboots
- All tools work together in harmony

This is a really clean setup that gives the isolation benefits of containers while leveraging the host's tooling and can be applied to most use cases (I recommend separation of concern here create containers for each development scenario e.g Ruby, Nodejs etc).

## Contributing

If you found this guide helpful, consider sharing it with the Bazzite/Universal Blue community on their Discord or GitHub discussions!

---

**Last Updated**: November 2025  
**Tested On**: Bazzite 43 (Fedora Core 43), NVIDIA Driver 580.95.05
