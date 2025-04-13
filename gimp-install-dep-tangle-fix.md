# gimp installation issues

When installing gimp on Debian based systems you might encounter a dependency tangle i.e. a package conflict between different versions of ODBC libraries (libodbc2 vs libodbc1, and libodbcinst2 vs odbcinst1debian2) — probably due to mixing packages from different repositories or a partial upgrade.

## How to fix

Thankfully there are a few steps we can perform to resolve this.

### Check for broken packages
The following command will check for any packages in a bad state (half installed).
```bash
dpkg -l | grep ^..r
```
<div style="border: 1px solid #ddd; padding: 10px; border-radius: 5px; background-color: #000;">
This command is doing two things connected by a pipe (`|`):

1. `dpkg -l` - This lists all packages in the Debian package management system. The `-l` flag stands for "list" and shows information about each package including its status, name, version, and description.

2. `grep ^..r` - This filters the output of the first command. Let's unpack this grep pattern:
   - `^` matches the beginning of a line
   - `.` is a wildcard that matches any single character
   - `..r` means "match any two characters followed by 'r'" at the beginning of a line

In the `dpkg -l` output, the first few characters of each line represent the package status. Specifically, the first three characters indicate:
- 1st character: desired package state (i=install, r=remove, p=purge, h=hold)
- 2nd character: current package state (n=not-installed, i=installed, etc.)
- 3rd character: error flags (space=no error, r=reinst-required, etc.)

So `grep ^..r` is looking for packages where the third character is 'r', which means packages that are marked as "reinst-required" - packages that need to be reinstalled because they're in a broken state.

This command is essentially finding all packages in your system that need to be reinstalled due to some error or corruption.
</div>

### Force install the conflicting packages
The new packages are trying to replace files that are owned by the older packages so we need to force the installation.
```bash
sudo dpkg -i --force-overwrite /var/cache/apt/archives/libodbc2_2.3.11-2+deb12u1_amd64.deb
sudo dpkg -i --force-overwrite /var/cache/apt/archives/unixodbc-common_2.3.11-2+deb12u1_all.deb
sudo dpkg -i --force-overwrite /var/cache/apt/archives/libodbcinst2_2.3.11-2+deb12u1_amd64.deb
```
This will tell `dpkg` to overwrite the conflicting files from the broken packages:
```bash
(Reading database ... 353499 files and directories currently installed.)
Preparing to unpack .../libodbc2_2.3.11-2+deb12u1_amd64.deb ...
Unpacking libodbc2:amd64 (2.3.11-2+deb12u1) ...
dpkg: warning: overriding problem because --force enabled:
dpkg: warning: trying to overwrite '/usr/lib/x86_64-linux-gnu/libodbc.so.2.0.0', which is also in package libodbc1:amd64 2.3.11-3
dpkg: warning: overriding problem because --force enabled:
dpkg: warning: trying to overwrite '/usr/lib/x86_64-linux-gnu/libodbc.so.2', which is also in package libodbc1:amd64 2.3.11-3
Setting up libodbc2:amd64 (2.3.11-2+deb12u1) ...
Processing triggers for libc-bin (2.36-9+deb12u10) ...
(Reading database ... 353502 files and directories currently installed.)
Preparing to unpack .../unixodbc-common_2.3.11-2+deb12u1_all.deb ...
Unpacking unixodbc-common (2.3.11-2+deb12u1) ...
dpkg: warning: overriding problem because --force enabled:
dpkg: warning: trying to overwrite '/etc/odbc.ini', which is also in package odbcinst 2.3.11-3
Setting up unixodbc-common (2.3.11-2+deb12u1) ...
Processing triggers for man-db (2.11.2-2) ...
(Reading database ... 353507 files and directories currently installed.)
Preparing to unpack .../libodbcinst2_2.3.11-2+deb12u1_amd64.deb ...
Unpacking libodbcinst2:amd64 (2.3.11-2+deb12u1) ...
dpkg: warning: overriding problem because --force enabled:
dpkg: warning: trying to overwrite '/usr/lib/x86_64-linux-gnu/libodbcinst.so.2.0.0', which is also in package odbcinst1debian2:amd64 2.3.11-3
dpkg: warning: overriding problem because --force enabled:
dpkg: warning: trying to overwrite '/usr/lib/x86_64-linux-gnu/libodbcinst.so.2', which is also in package odbcinst1debian2:amd64 2.3.11-3
Setting up libodbcinst2:amd64 (2.3.11-2+deb12u1) ...
Processing triggers for libc-bin (2.36-9+deb12u10) ...
```

### Fix and clean up
When all the conflicts have been resolved we need to finish the setup:
```bash
sudo apt --fix-broken install
```

### Install gimp
Finally we should be able to install `gimp` app without any issues:
```bash
sudo apt install gimp
```

## Finishing up
You should now have `gimp` working and I highly recommend something like `LibreOffice Draw` which comes pre-installed in MX Linux (my current distro of choice based on `Debian 12`) and equally good is [draw.io](https://draw.io) both make great companions to `gimp`.

Now go get creative!

_Lookout for a future write up on the basics of `gimp` it can be a bit daunting at first hopefully I will help you get started in the right direction :-)_
