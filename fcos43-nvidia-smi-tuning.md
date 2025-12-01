# NVIDIA Performance Configuration Guide for Bazzite/Fedora Immutable (FCOS 43)

## Problem Overview

On Bazzite (and other Fedora immutable distros) with NVIDIA GPUs, the GPU may stay at the lowest performance level (P8 state) even during gaming, causing poor performance. This happens because the GPU doesn't automatically ramp up to higher power states under load.

## Hardware Details

This guide was tested with:
- **OS**: Bazzite 43 (Fedora Core 43 immutable)
- **GPU**: NVIDIA Quadro T2000 with Max-Q Design
- **Driver**: 580.95.05
- **CUDA**: 13.0
- Platform: Dell Precision 5550 i9-10885H, 64GB DDR4 RAM, Toshiba nVME 2.0 512GB drive
- Game(s): World of Warcraft WOTLK Warmane Edition, Gauntlet (Steam)

## Game Tuning
If you are using Lutris you may need to enable VKD3D and add the following environment details under System options:
- **KEY** `DXVK_ASYNC` **VALUE** `1`
- **KEY** `DXVK_HUD` **VALUE** `fps`
- **KEY** `__GLX_VENDOR_LIBRARY_NAME` **VALUE** `nvidia`
- **KEY** `__NV_PRIME_RENDER_OFFLOAD` **VALUE** `1`

**Note:** Future guide coming soon "How to setup Lutris correctly and configure various types of games and common issue resolutions"

The same principles apply to other NVIDIA GPUs on Bazzite/Fedora immutable systems.

## Solution: Manual Performance Configuration

### Step 1: Verify NVIDIA Drivers Are Working

Since you're using the `bazzite-gnome-nvidia` image, drivers should already be installed. Verify with:

```bash
nvidia-smi
```

You should see your GPU information displayed.

### Step 2: Check Supported Clock Speeds

Find out what clock speeds your GPU supports:

```bash
nvidia-smi -q -d SUPPORTED_CLOCKS
```

For the Quadro T2000, the supported clocks are:
- **Memory**: 5001 MHz (max), 810 MHz (mid), 405 MHz (low)
- **Graphics**: 300-2100 MHz

### Step 3: Check Current Power Settings

```bash
nvidia-smi -q -d POWER
```

This shows your current and maximum power limits.

### Step 4: Enable Performance Mode and Lock Clocks

```bash
# Enable persistent performance mode
sudo nvidia-smi -pm 1

# Lock clocks to maximum (adjust values for your GPU)
sudo nvidia-smi -ac 5001,2100

# Verify the changes
nvidia-smi
```

The `-ac` flag syntax is: `nvidia-smi -ac <memory_clock>,<graphics_clock>`

### Step 5: Create Convenient Aliases

Add these to your `~/.bashrc` or `~/.bash_aliases`:

```bash
# GPU performance aliases (adjust clock speeds for your GPU)
alias gpu-max='sudo nvidia-smi -pm 1 && sudo nvidia-smi -ac 5001,2100 && echo "GPU: Maximum Performance (2100MHz)"'
alias gpu-high='sudo nvidia-smi -pm 1 && sudo nvidia-smi -ac 5001,1800 && echo "GPU: High Performance (1800MHz)"'
alias gpu-conservative='sudo nvidia-smi -pm 1 && sudo nvidia-smi -ac 5001,1200 && echo "GPU: Conservative Performance (1200MHz)"'
alias gpu-auto='sudo nvidia-smi -pm 0 && sudo nvidia-smi -rac && echo "GPU: Auto clocks restored"'
alias gpu-status='nvidia-smi && nvidia-smi -q -d PERFORMANCE | grep -E "Performance State|Clocks"'
alias gpu-watch='watch -n 1 nvidia-smi'
```

Reload your shell:

```bash
source ~/.bashrc
```

Now you can easily switch performance modes:
- `gpu-max` - Maximum performance for demanding games
- `gpu-high` - High performance, slightly lower clocks
- `gpu-conservative` - Balanced performance for lighter workloads
- `gpu-auto` - Return to automatic clock management
- `gpu-status` - Check current GPU status
- `gpu-watch` - Monitor GPU in real-time

## Making Settings Persistent (Optional)

To automatically apply performance settings on boot, create a systemd service:

### Create the Service File

```bash
sudo nano /etc/systemd/system/nvidia-performance.service
```

### Add This Content

```ini
[Unit]
Description=NVIDIA GPU Performance Settings
After=nvidia-persistenced.service

[Service]
Type=oneshot
ExecStart=/usr/bin/nvidia-smi -pm 1
ExecStart=/usr/bin/nvidia-smi -ac 5001,2100
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

**Note**: Adjust the clock speeds in the `ExecStart` line to match your GPU's capabilities.

### Enable the Service

```bash
sudo systemctl daemon-reload
sudo systemctl enable nvidia-performance.service
sudo systemctl start nvidia-performance.service
```

### Verify It's Running

```bash
sudo systemctl status nvidia-performance.service
```

## Monitoring GPU Performance

### Using nvtop (Recommended)

Install if not already available:

```bash
rpm-ostree install nvtop
systemctl reboot
```

Then run:

```bash
nvtop
```

This provides a real-time view of GPU usage, clocks, memory, and temperature.

### Using nvidia-smi

```bash
# Single snapshot
nvidia-smi

# Continuous monitoring
watch -n 1 nvidia-smi

# Detailed performance info
nvidia-smi -q -d PERFORMANCE
```

## Troubleshooting

### GPU Still Not Ramping Up

1. Check if performance mode is enabled:
   ```bash
   nvidia-smi -q -d PERFORMANCE | grep "Performance Mode"
   ```

2. Verify clocks are locked:
   ```bash
   nvidia-smi -q -d CLOCKS
   ```

3. Check for thermal throttling:
   ```bash
   nvidia-smi -q -d TEMPERATURE
   ```

### Settings Not Persisting After Reboot

If using the systemd service and settings don't persist:

1. Check service status:
   ```bash
   sudo systemctl status nvidia-performance.service
   ```

2. Check service logs:
   ```bash
   journalctl -u nvidia-performance.service
   ```

3. Ensure the service is enabled:
   ```bash
   sudo systemctl is-enabled nvidia-performance.service
   ```

### Permission Issues with Aliases

If you get permission errors when using the aliases, you may need to configure passwordless sudo for nvidia-smi commands. Edit sudoers:

```bash
sudo visudo
```

Add this line (replace `yourusername` with your actual username):

```bash
yourusername ALL=(ALL) NOPASSWD: /usr/bin/nvidia-smi
```

## Understanding nvidia-smi Flags

- `-pm 1` - Enable persistent mode (keeps driver loaded, reduces latency)
- `-pm 0` - Disable persistent mode (auto management)
- `-ac <mem>,<gpu>` - Lock application clocks to specified MHz
- `-rac` - Reset application clocks to default (auto)
- `-pl <watts>` - Set power limit in watts
- `-q -d <section>` - Query detailed information for a specific section

## Performance vs Battery Life (Laptops)

If you're on a laptop:

- **Gaming on AC power**: Use `gpu-max`
- **Light work on battery**: Use `gpu-auto` or `gpu-conservative`
- **Maximum battery life**: Use `gpu-auto` and let the GPU idle at P8 state

Locked clocks will drain battery faster even when idle, so remember to run `gpu-auto` when you're done gaming.

## Additional Resources

- [NVIDIA Driver Documentation](https://docs.nvidia.com/cuda/)
- [Bazzite Documentation](https://universal-blue.org/images/bazzite/)
- [nvidia-smi Documentation](https://developer.nvidia.com/nvidia-system-management-interface)

## Contributing

If you found this guide helpful, consider sharing it with the Bazzite/Universal Blue community on their Discord or GitHub discussions!

---

**Last Updated**: November 2025  
**Tested On**: Bazzite 43 (*Fedora Core 43*), NVIDIA Driver 580.95.05
