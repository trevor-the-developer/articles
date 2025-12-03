# Bazzite (Fedora Core 43 based) Linux
## Distrobox Development Essentials Container Setup Guide

This guide will detail how to setup a Distrobox container for general development purposes (building an application or package from source for example).

### Key Points for Bazzite/Fedora 43:

- RPM packaging tools are essential - you'll need rpmbuild to create packages
- Systemd-devel - many Fedora packages depend on systemd APIs
- Wayland + X11 - support both display protocols
- GTK4/GTK3 - most Fedora GUI apps use GTK
- Python/Rust/Go - modern build systems often use these

### Prerequisites

Ensure your Bazzite distro is updated:
```bash
ujust update
```

Distrobox installed

### Distrobox setup

Create a new Fedora Core 43 based container:
```bash
distrobox create --name dev-tools --image quay.io/fedora/fedora:43
```

Enter the container and perform the initial setup:
```bash
distrobox enter dev-tools
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

Update the container:
```bash
sudo dnf update
```

### Recommended Minimal Setup:

For a focused build container the following can be installed:
```bash
sudo dnf groupinstall "Development Tools"
sudo dnf install rpm-build rpmdevtools redhat-rpm-config
sudo dnf install cmake meson ninja-build autoconf automake libtool pkgconf-pkg-config
sudo dnf install gtk3-devel glib2-devel systemd-devel
sudo dnf install python3-devel rust cargo golang
sudo dnf install wayland-devel libX11-devel mesa-libGL-devel
sudo dnf install ffmpeg-devel curl-devel openssl-devel
```

### Comprehensive Setup:

The following tools and packages give a comprehensive setup.

### Essential Build Dependencies:

```bash
# Development tools and libraries
sudo dnf groupinstall "Development Tools" "Development Libraries" "C Development Tools and Libraries"

# Build systems
sudo dnf install cmake meson ninja-build autoconf automake libtool

# Compilers and linkers (additional to what's in groups)
sudo dnf install gcc-gfortran clang clang-devel lld llvm llvm-devel

# Package config
sudo dnf install pkgconf-pkg-config

# RPM packaging tools (for building packages in container)
sudo dnf install rpm-build rpmdevtools rpmlint spectool dnf-utils redhat-rpm-config

# Internationalization
sudo dnf install gettext-devel intltool
```

*The `dnf group install` command in Fedora is used to install predefined collections of related packages called package groups. These groups bundle together software packages that serve a common purpose, making it much easier to install multiple related tools with a single command rather than installing each package individually. The `groupinstall` is a shorthand for the same command.*

### Library Headers for Common Dependencies:

```bash
# GTK/GNOME stack (common in Fedora apps)
sudo dnf install gtk3-devel gtk4-devel gtk-doc libadwaita-devel
sudo dnf install glib2-devel gobject-introspection-devel
sudo dnf install pango-devel cairo-devel gdk-pixbuf2-devel
sudo dnf install vala vala-devel

# System libraries
sudo dnf install systemd-devel dbus-devel polkit-devel
sudo dnf install libappstream-glib-devel libappstream-devel

# File/IO libraries
sudo dnf install libarchive-devel liburing-devel
sudo dnf install fuse-devel fuse3-devel

# Network/Web
sudo dnf install libsoup-devel webkitgtk-devel
```

### Language Runtimes for Building:

```bash
# Python (many build scripts use Python)
sudo dnf install python3-devel python3-pip python3-setuptools python3-wheel
sudo dnf install python3-virtualenv python3-pytest python3-build

# JavaScript/Node (for Electron apps, node modules)
sudo dnf install nodejs npm nodejs-packaging

# Rust (increasingly common in Fedora packages)
sudo dnf install rust cargo rust-src cargo-packaging

# Go (some newer tools are written in Go)
sudo dnf install golang golang-misc

# Ruby (some build scripts and tools)
sudo dnf install ruby ruby-devel rubygems rubygem-rake

# Perl (some legacy build scripts)
sudo dnf install perl-devel perl-ExtUtils-MakeMaker
```

### Graphics/Media Stack:

```bash
# Wayland (primary for modern Fedora)
sudo dnf install wayland-devel wayland-protocols-devel

# X11 compatibility
sudo dnf install libX11-devel libXext-devel libXrandr-devel
sudo dnf install libXinerama-devel libXcursor-devel libXi-devel
sudo dnf install libXfixes-devel libXrender-devel libXcomposite-devel

# OpenGL/Vulkan
sudo dnf install mesa-libGL-devel mesa-libGLU-devel
sudo dnf install vulkan-devel vulkan-headers vulkan-loader-devel

# Windowing toolkits
sudo dnf install qt5-qtbase-devel qt5-qttools-devel
sudo dnf install SDL2-devel SDL2_ttf-devel SDL2_net-devel
```

### Audio/Media:
```bash
# Audio backends
sudo dnf install alsa-lib-devel pulseaudio-libs-devel
sudo dnf install pipewire-devel  # Bazzite uses PipeWire
sudo dnf install jack-audio-connection-kit-devel

# Media libraries
sudo dnf install ffmpeg-devel
sudo dnf install gstreamer1-devel gstreamer1-plugins-base-devel

# Hardware acceleration
sudo dnf install libva-devel libvdpau-devel
```

### Network/Web:
```bash
# Networking
sudo dnf install openssl-devel curl-devel
sudo dnf install libssh-devel libssh2-devel
sudo dnf install nghttp2-devel c-ares-devel

# Web/Internet  
sudo dnf install libsoup-devel webkitgtk-devel
sudo dnf install libxml2-devel libxslt-devel
sudo dnf install json-c-devel yajl-devel
```

### Specialized Build Dependencies:
```bash
# Compression libraries
sudo dnf install zlib-devel bzip2-devel xz-devel
sudo dnf install libzstd-devel lz4-devel

# Database clients (for apps that need DB access)
sudo dnf install sqlite-devel

# Security
sudo dnf install libsodium-devel libgcrypt-devel
```

### Debugging & QA:
```bash
# Debug symbols generation
sudo dnf install debugedit dwz

# Sanitizers
sudo dnf install libasan libubsan libtsan

# Memory/runtime debugging
sudo dnf install valgrind valgrind-devel gdb strace ltrace

# Linters/analyzers
sudo dnf install clang-tools-extra cppcheck flawfinder

# Performance
sudo dnf install perf systemtap-sdt-devel
```

## Contributing

If you found this guide helpful, consider sharing it with the Bazzite/Universal Blue community on their Discord or GitHub discussions!

---

**Last Updated**: December 2025  
**Tested On**: Bazzite 43 (*Fedora Core 43*)