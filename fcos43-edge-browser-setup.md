# Bazzite (Fedora Core 43 based) Linux
## Microsoft Edge Web Browser Setup Guide

This guide will detail how to setup Microsoft Edge Browser inside a Debian based Distrobox Container.

### Debian based Distrobox container
Create a new distrobox container if you don't want to reuse an existing Debian based distro (`--name` can be whatever you want to call it):
```bash
distrobox create --name deb-apps --nvidia --image docker.io/debian/eol:bullseye
```
Enter the container:
```bash
distrobox enter deb-apps
```
Update the sudoer file:
```bash
sudo apt install nano

sudo visudo
```
Scroll to the bottom find the line that reads:
```bash
root    ALL=(ALL:ALL) ALL
```
Add the following below that line:
```bash
trevor  ALL=(ALL:ALL) ALL
```
Where `trevor` is your username then save the file and update the container:
```bash
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
```

## Install and Setup

Run the following command to output the architecture of your Distrobox container:
```bash
dpkg --print-architecture
```

If the output is amd64, set up Microsoft's Edge repository and install:

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
sudo chmod a+r /etc/apt/keyrings/microsoft.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main' | sudo tee /etc/apt/sources.list.d/microsoft-edge-stable.list > /dev/null
sudo apt update
sudo apt install microsoft-edge-stable
```

This adds Microsoft's signing key in the modern keyrings location, registers the official Edge repo, then installs Edge. Future updates will arrive with apt upgrade.

Type `which microsoft-edge` to confirm installation path `/usr/bin/microsoft-edge`.  Now export the application to the host:
```bash
distrobox-export --bin /usr/bin/microsoft-edge --export-path ~/.local/bin
```

### Create Gnome Desktop icon

For gnome you can create a Gnome Launcher icon located in `./local/share/applications` called `ms-edge.desktop` using your favourite editor (Nano, or Micro are good terminal based editors) and paste in the following:
```bash
[Desktop Entry]
Name=Microsoft Edge
Comment=Your AI-powered browser
GenericName=Web Browser
Exec=/usr/bin/distrobox-enter  -n deb-apps  --   microsoft-edge
Icon=web-browser-symbolic
Type=Application
StartupNotify=false
StartupWMClass=Edge
Categories=WebBrowser;Browser;
Keywords=edge;
```

The Icon value can be changed for any of the 48 Adwaita icons see [here](https://github.com/StorageB/icons/blob/main/GNOME48Adwaita/icons.md)

Save the file then update the desktop database:
```bash
update-desktop-database ~/.local/share/applications/
```

## Testing

Press the super-key and type `edge` you should see the new Microsoft Edge browser icon left-click to launch the app.

## Contributing

If you found this guide helpful, consider sharing it with the Bazzite/Universal Blue community on their Discord or GitHub discussions!

---

**Last Updated**: December 2025  
**Tested On**: Bazzite 43 (*Fedora Core 43*)
