# ProtonVPN OpenVPN Setup Guide for Arch Linux

This guide walks you through setting up ProtonVPN using the OpenVPN client on Arch Linux.

## Prerequisites

- Arch Linux (or Arch-based distribution like Omarchy)
- Active ProtonVPN account (free or paid)
- Terminal access with sudo privileges

## Step 1: Install OpenVPN

Install the OpenVPN client:

```bash
sudo pacman -S openvpn
```

## Step 2: Install the DNS Resolution Script

The ProtonVPN configuration files require a DNS update script. Create a symlink to the OpenVPN contrib script:

```bash
sudo ln -s /usr/share/openvpn/contrib/pull-resolv-conf/client.up /etc/openvpn/update-resolv-conf
```

Verify the symlink was created:

```bash
ls -la /etc/openvpn/update-resolv-conf
```

You should see it pointing to `/usr/share/openvpn/contrib/pull-resolv-conf/client.up`

## Step 3: Download ProtonVPN OpenVPN Configuration Files

1. Log into your ProtonVPN account at [https://account.protonvpn.com](https://account.protonvpn.com)
2. Navigate to **Downloads** → **OpenVPN configuration files**
3. Select your platform (Linux)
4. Choose the protocol: **UDP** (recommended) or TCP
5. Download configuration files for the servers you want to use (e.g., Netherlands, US, etc.)

## Step 4: Get Your OpenVPN Credentials

**Important:** OpenVPN uses different credentials than your regular ProtonVPN login!

1. Log into your ProtonVPN account at [https://account.protonvpn.com](https://account.protonvpn.com)
2. Go to **Account** → **OpenVPN / IKEv2 username**
3. Copy your **OpenVPN/IKEv2 username** (NOT your email address)
4. Copy your **OpenVPN/IKEv2 password** (NOT your account password)

Save these credentials - you'll need them for authentication.

## Step 5: Organize Your Configuration Files

Create a directory to store your OpenVPN configuration files:

```bash
mkdir -p ~/.config/ovpn
```

Move your downloaded `.ovpn` files to this directory:

```bash
mv ~/Downloads/*.ovpn ~/.config/ovpn/
```

## Step 6: Create an Authentication File

To avoid typing your credentials every time you connect, create an authentication file:

```bash
nano ~/.config/ovpn/auth.txt
```

Add your OpenVPN credentials (one per line):

```
your_openvpn_username
your_openvpn_password
```

Save the file (Ctrl+X, then Y, then Enter).

Secure the file so only you can read it:

```bash
chmod 600 ~/.config/ovpn/auth.txt
```

## Step 7: Test the Connection

Test your VPN connection manually:

```bash
sudo openvpn --config ~/.config/ovpn/nl-free-145.protonvpn.udp.ovpn --auth-user-pass ~/.config/ovpn/auth.txt
```

Replace `nl-free-145.protonvpn.udp.ovpn` with the name of your configuration file.

You should see output ending with:
```
Peer Connection Initiated with [AF_INET]...
```

To disconnect, press `Ctrl+C`.

## Step 8: Verify Your VPN Connection

Check that your IP address has changed:

```bash
curl ifconfig.me
```

This should show the IP address of the VPN server (not your real IP).  You can check this by going to the following location: https://ip.me/ enter the IP address to do a lookup and you can also check the IP address against what is being shown by the website.

## Step 9: Create Convenient Aliases (Optional)

Add aliases to your shell configuration file for easy VPN management.

For **bash**, edit `~/.bashrc`:

```bash
nano ~/.bashrc
```

For **zsh**, edit `~/.zshrc`:

```bash
nano ~/.zshrc
```

Add the following aliases (adjust the config file name as needed):

```bash
# ProtonVPN aliases
alias vpn-start='sudo openvpn --config ~/.config/ovpn/nl-free-145.protonvpn.udp.ovpn --auth-user-pass ~/.config/ovpn/auth.txt'
alias vpn-ip='curl ifconfig.me'
```

Save the file and reload your shell configuration:

```bash
source ~/.bashrc  # or source ~/.zshrc
```

Now you can simply run:

```bash
vpn-start      # Connect to VPN
vpn-ip         # Check your current IP
```

Press `Ctrl+C` to disconnect.

## Alternative: Systemd Service (Background Operation)

If you prefer the VPN to run in the background, you can set it up as a systemd service.

1. Copy your configuration file to the systemd directory:

```bash
sudo cp ~/.config/ovpn/nl-free-145.protonvpn.udp.ovpn /etc/openvpn/client/protonvpn.conf
```

2. Update the config to use your auth file. Edit the systemd config:

```bash
sudo nano /etc/openvpn/client/protonvpn.conf
```

Add this line after the first few lines:

```
auth-user-pass /home/YOUR_USERNAME/.config/ovpn/auth.txt
```

Replace `YOUR_USERNAME` with your actual username.

3. Control the VPN service:

```bash
# Start VPN
sudo systemctl start openvpn-client@protonvpn

# Stop VPN
sudo systemctl stop openvpn-client@protonvpn

# Check status
sudo systemctl status openvpn-client@protonvpn

# View live logs
sudo journalctl -u openvpn-client@protonvpn -f

# Enable on boot (optional)
sudo systemctl enable openvpn-client@protonvpn
```

## Troubleshooting

### Authentication Failed Error

If you see `AUTH_FAILED`, double-check:
- You're using **OpenVPN/IKEv2 credentials** (not your regular account login)
- Your credentials are correct in `~/.config/ovpn/auth.txt`
- There are no extra spaces or characters in the auth file

### DNS Script Error

If you see an error about `/etc/openvpn/update-resolv-conf` not found:
- Verify the symlink exists: `ls -la /etc/openvpn/update-resolv-conf`
- Recreate it if needed (see Step 2)

### Connection Works But No Internet

Check your DNS:
```bash
cat /etc/resolv.conf
```

You may need to restart NetworkManager:
```bash
sudo systemctl restart NetworkManager
```

## Managing Multiple VPN Servers

You can download multiple `.ovpn` files for different countries and create separate aliases:

```bash
alias vpn-nl='sudo openvpn --config ~/.config/ovpn/nl-free-145.protonvpn.udp.ovpn --auth-user-pass ~/.config/ovpn/auth.txt'
alias vpn-us='sudo openvpn --config ~/.config/ovpn/us-free-01.protonvpn.udp.ovpn --auth-user-pass ~/.config/ovpn/auth.txt'
alias vpn-uk='sudo openvpn --config ~/.config/ovpn/uk-free-01.protonvpn.udp.ovpn --auth-user-pass ~/.config/ovpn/auth.txt'
```

## Security Notes

- Your `auth.txt` file contains sensitive credentials - keep it secure with `chmod 600`
- Never share or commit this file to version control
- Consider using a password manager to store these credentials
- The OpenVPN process runs as root (required for network configuration)

## Additional Resources

- ProtonVPN Support: [https://protonvpn.com/support](https://protonvpn.com/support)
- OpenVPN Documentation: [https://openvpn.net/community-resources/](https://openvpn.net/community-resources/)
- Arch Wiki OpenVPN: [https://wiki.archlinux.org/title/OpenVPN](https://wiki.archlinux.org/title/OpenVPN)

---

**Setup completed!** You now have a fully functional ProtonVPN OpenVPN client on Arch Linux.
