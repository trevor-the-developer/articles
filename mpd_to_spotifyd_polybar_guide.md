# 🎵 Replace MPD with Spotify in Archcraft Polybar

This guide shows how to replace the default MPD (Music Player Daemon) module in Archcraft's Polybar with Spotify integration using Spotifyd and Playerctl.

## 📋 Prerequisites

- Archcraft Linux installation
- Polybar configuration (default Archcraft theme)
- Spotify account
- KeepassXC (optional, for secure password management)

## 🔧 Installation

### Step 1: Install Required Packages

```bash
yay -S spotifyd playerctl --noconfirm
```

### Step 2: Backup Your Configuration

```bash
cd ~/.config/openbox/themes/default/polybar
cp modules.ini modules.ini.backup
```

## 📝 Configuration Changes

### Step 3: Update modules.ini

Replace the MPD module with Spotify module:

**Find this section (around line 416):**
```ini
[module/mpd]
type = internal/mpd
# ... (entire MPD configuration)
```

**Replace with:**
```ini
[module/spotify]
type = custom/script
exec = ~/.config/openbox/themes/default/polybar/scripts/spotify-controls.sh
interval = 2
format = <label>
format-background = ${color.ALTBACKGROUND}
format-padding = 1
label = %output%
click-left = playerctl play-pause
click-right = playerctl next
click-middle = playerctl previous
scroll-up = playerctl next
scroll-down = playerctl previous
```

**Find the song module (around line 432):**
```ini
[module/song]
type = internal/mpd
# ... (entire song configuration)
```

**Replace with:**
```ini
[module/spotify-song]
type = custom/script
exec = ~/.config/openbox/themes/default/polybar/scripts/spotify-song.sh
interval = 2
format = <label>
format-font = 5
label = %output%
label-maxlen = 25
label-ellipsis = true
```

### Step 4: Update config.ini

**Find line 148:**
```ini
modules-center = LD date RD dot-alt LD mpd RD sep song
```

**Replace with:**
```ini
modules-center = LD date RD dot-alt LD spotify RD sep spotify-song
```

## 📜 Create Scripts

### Step 5: Create Scripts Directory and Files

```bash
mkdir -p ~/.config/openbox/themes/default/polybar/scripts
```

### Step 6: Create spotify-controls.sh

```bash
nano ~/.config/openbox/themes/default/polybar/scripts/spotify-controls.sh
```

**Content:**
```bash
#!/bin/bash

# Check if Spotify is running
if ! pgrep -x "spotify" > /dev/null; then
    echo "󰝚 Spotify Offline"
    exit 0
fi

# Check if playerctl can find spotify
if ! playerctl --player=spotify status > /dev/null 2>&1; then
    echo "󰝚 Spotify Not Playing"
    exit 0
fi

# Get current status
STATUS=$(playerctl --player=spotify status 2>/dev/null)

# Define icons
PLAY_ICON="󰐊"
PAUSE_ICON="󰏤"
PREV_ICON="󰒮"
NEXT_ICON="󰒭"

# Output the controls based on status
case $STATUS in
    "Playing")
        echo "${PREV_ICON} ${PAUSE_ICON} ${NEXT_ICON}"
        ;;
    "Paused")
        echo "${PREV_ICON} ${PLAY_ICON} ${NEXT_ICON}"
        ;;
    *)
        echo "${PREV_ICON} ${PLAY_ICON} ${NEXT_ICON}"
        ;;
esac
```

### Step 7: Create spotify-song.sh

```bash
nano ~/.config/openbox/themes/default/polybar/scripts/spotify-song.sh
```

**Content:**
```bash
#!/bin/bash

# Check if Spotify is running
if ! pgrep -x "spotify" > /dev/null; then
    echo "󰝚 Offline"
    exit 0
fi

# Check if playerctl can find spotify
if ! playerctl --player=spotify status > /dev/null 2>&1; then
    echo "󰝚 Not Playing"
    exit 0
fi

# Get current status
STATUS=$(playerctl --player=spotify status 2>/dev/null)

# If not playing, show paused or stopped status
if [ "$STATUS" != "Playing" ]; then
    echo "󰝚 $STATUS"
    exit 0
fi

# Get song information
ARTIST=$(playerctl --player=spotify metadata artist 2>/dev/null)
TITLE=$(playerctl --player=spotify metadata title 2>/dev/null)

# If we have both artist and title, display them
if [ -n "$ARTIST" ] && [ -n "$TITLE" ]; then
    echo "󰝚 $TITLE"
else
    echo "󰝚 Unknown"
fi
```

### Step 8: Make Scripts Executable

```bash
chmod +x ~/.config/openbox/themes/default/polybar/scripts/spotify-controls.sh
chmod +x ~/.config/openbox/themes/default/polybar/scripts/spotify-song.sh
```

## 🔒 Spotifyd Configuration (Optional)

### Step 9: Create Spotifyd Config

```bash
mkdir -p ~/.config/spotifyd
nano ~/.config/spotifyd/spotifyd.conf
```

**Content:**
```ini
[global]
# Your Spotify username
username = "YOUR_SPOTIFY_USERNAME"

# Use KeepassXC to retrieve password securely (recommended)
password_cmd = "keepassxc-cli show -s -a password /path/to/your/database.kdbx Spotify"

# Or use plain text password (not recommended)
# password = "YOUR_SPOTIFY_PASSWORD"

# The audio backend to use
backend = "pulseaudio"

# The name that will be displayed under the connect tab
device_name = "spotifyd"

# The audio bitrate. 96, 160 or 320 kbit/s
bitrate = 320

# The directory used to cache audio data
cache_path = "/tmp/spotifyd"

# Volume on startup between 0 and 100
initial_volume = "90"

# If set to true, enables volume normalisation between songs
volume_normalisation = true

# The normalisation pregain that is applied for each song
normalisation_pregain = -10

# The displayed device type in Spotify clients
device_type = "computer"
```

### Step 10: KeepassXC Integration (Recommended)

1. **Create Spotify entry in KeepassXC:**
   - Open KeepassXC
   - Create new entry titled "Spotify"
   - Set username to your Spotify username
   - Set password to your Spotify password

2. **Update spotifyd.conf:**
   - Replace `YOUR_SPOTIFY_USERNAME` with your actual username
   - Update `/path/to/your/database.kdbx` with your KeepassXC database path

3. **Test the integration:**
   ```bash
   keepassxc-cli show -s -a password /path/to/your/database.kdbx Spotify
   ```

## 🚀 Testing and Activation

### Step 11: Test Scripts

```bash
# Test the control script
~/.config/openbox/themes/default/polybar/scripts/spotify-controls.sh

# Test the song script
~/.config/openbox/themes/default/polybar/scripts/spotify-song.sh
```

### Step 12: Start Spotifyd (Optional)

```bash
# Enable and start spotifyd service
systemctl --user enable spotifyd
systemctl --user start spotifyd
```

### Step 13: Restart Polybar

```bash
pkill polybar && ~/.config/openbox/themes/default/polybar/launch.sh
```

## ✨ Features

- **🎮 Interactive Controls:** 
  - Left-click: Play/Pause
  - Right-click: Next track
  - Middle-click: Previous track
  - Scroll up/down: Next/Previous track

- **📱 Status Display:**
  - Shows current song title
  - Displays playback status (Playing/Paused)
  - Shows offline status when Spotify not running

- **🔒 Secure Authentication:**
  - KeepassXC integration for password management
  - No plain text passwords in config files

- **🎨 Visual Consistency:**
  - Maintains original Archcraft theme styling
  - Uses Nerd Font icons for modern look

## 🔧 Troubleshooting

### Common Issues:

1. **Scripts not working:**
   ```bash
   # Check if scripts are executable
   ls -la ~/.config/openbox/themes/default/polybar/scripts/
   
   # Make executable if needed
   chmod +x ~/.config/openbox/themes/default/polybar/scripts/*.sh
   ```

2. **Spotify not detected:**
   ```bash
   # Check if Spotify is running
   pgrep -x spotify
   
   # Check playerctl
   playerctl --player=spotify status
   ```

3. **Polybar not updating:**
   ```bash
   # Restart polybar
   pkill polybar && ~/.config/openbox/themes/default/polybar/launch.sh
   ```

4. **Icons not showing:**
   - Ensure you have Nerd Fonts installed
   - Check if your terminal supports Unicode

## 📁 File Structure

After completion, your file structure should look like:

```
~/.config/openbox/themes/default/polybar/
├── config.ini                    # Modified
├── modules.ini                   # Modified
├── modules.ini.backup             # Backup
└── scripts/
    ├── spotify-controls.sh        # New
    ├── spotify-song.sh            # New
    └── bluetooth.sh               # Existing

~/.config/spotifyd/
└── spotifyd.conf                  # New (optional)
```

## 🎯 Result

You'll get a fully functional Spotify integration in your Archcraft Polybar that:
- Shows current song title
- Provides interactive playback controls
- Handles offline states gracefully
- Maintains the original theme aesthetics
- Uses secure password management

---

**Tested on:** Archcraft with Openbox + Polybar
**Requirements:** spotifyd, playerctl, KeepassXC (optional)
**Theme:** Default Archcraft theme

Feel free to customize the scripts and configuration to match your preferences!
