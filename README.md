# UCAN Automation in Wireless Network Configurations: Streamlining AP Setup with Raspberry Pi Testbeds
# Raspberry Pi Wi-Fi Configuration Scripts

This repository contains Bash scripts to configure a Raspberry Pi as a Wi-Fi Access Point (AP), enable AP mode with NAT, and revert to Client Mode.

## Scripts Overview

### 1. Configure Raspberry Pi as a Wi-Fi Access Point
This script sets up a Raspberry Pi as a Wi-Fi AP using `hostapd`. It allows customization of SSID, hardware mode, channel, and password.

#### Usage:
```bash
sudo ./ap_config.sh -s <SSID> -m <hw_mode> -c <channel> -p <password>
```

#### Arguments:
- `-s`: SSID for the Access Point.
- `-m`: Hardware mode (`g` for 2.4GHz, `a` for 5GHz).
- `-c`: Channel number.
- `-p`: Wi-Fi password (minimum 8 characters).

#### Features:
- Displays the existing `hostapd` configuration.
- Validates required arguments.
- Generates a new `hostapd` configuration file.
- Updates `/etc/default/hostapd`.
- Restarts `hostapd` service.

---

### 2. Configure Raspberry Pi as a Wi-Fi Access Point with NAT
This script enables NAT and DHCP for internet sharing on a Raspberry Pi acting as an AP.

#### Usage:
```bash
sudo ./ap_mode.sh
```

#### Features:
- Installs required packages (`hostapd`, `dnsmasq`, `iptables-persistent`).
- Configures DHCP and assigns a static IP (`192.168.4.1/24`).
- Enables NAT and IP forwarding.
- Sets up `hostapd` with default settings.
- Stops conflicting services (`wpa_supplicant`, `NetworkManager`).
- Reboots the system for changes to take effect.

#### Troubleshooting:
- Check `hostapd` logs: `sudo journalctl -u hostapd`.
- Verify NAT rules: `sudo iptables -t nat -L`.
- Ensure `wlan0` is in AP mode: `sudo iw dev wlan0 info`.

---

### 3. Revert Raspberry Pi from Access Point Mode to Client Mode
This script disables AP services and restores client mode functionality.

#### Usage:
```bash
sudo ./client_mode.sh
```

#### Features:
- Stops and disables `hostapd` and `dnsmasq`.
- Re-enables `wpa_supplicant` and `NetworkManager`.
- Restores DHCP configuration.
- Removes NAT rules and disables IP forwarding.
- Resets `wlan0` to managed mode.
- Reboots the system for changes to apply.

#### Troubleshooting:
- Verify `wlan0` is in managed mode: `sudo iw dev wlan0 info`.
- Check `wpa_supplicant` status: `sudo systemctl status wpa_supplicant`.
- Ensure NAT rules are removed: `sudo iptables -t nat -L`.

---

## Notes
- The scripts assume `wlan0` is the primary wireless interface. Modify if needed.
- Always back up configuration files before making changes.
- Run all scripts with `sudo`.

