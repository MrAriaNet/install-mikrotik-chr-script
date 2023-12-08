# Install-MikroTik-CHR-on-VPS
Easy way for install Mikrotik’s Cloud Hosted Router on any Cloud VM

## Installation

For MikroTik 7.10.2

```bash
  bash -c "$(curl -L https://raw.githubusercontent.com/parhamfa/install-mikrotik-chr-script/main/installer.sh)"
```

## Find information manually
Find storage name
```bash
lsblk | grep disk | cut -d ' ' -f 1 | head -n 1
```
Find ethernet name
```bash
ip route show default | sed -n 's/.* dev \([^\ ]*\) .*/\1/p'
```
find ip address name
```bash
ip addr show $ETH | grep global | cut -d' ' -f 6 | head -n 1
```
find gateway name
```bash
ip route list | grep default | cut -d' ' -f 3
```

