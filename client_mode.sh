#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

echo "Reverting system to normal client mode..."

# Stop and disable services related to AP mode
echo "Disabling hostapd and dnsmasq services..."
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq
sudo systemctl disable hostapd
sudo systemctl disable dnsmasq

# Revert dhcpcd configuration for default network management
echo "Restoring dhcpcd configuration..."
cat <<EOF > /etc/dhcpcd.conf
# Default configuration for dhcpcd
# Allow dhcpcd to manage wlan0 (client mode)
interface wlan0
EOF

# Revert hostapd configuration to default
echo "Restoring hostapd configuration..."
rm -f /etc/hostapd/hostapd.conf

# Revert /etc/default/hostapd to default
echo "Restoring /etc/default/hostapd..."
sudo sed -i 's|DAEMON_CONF="/etc/hostapd/hostapd.conf"|#DAEMON_CONF=""|' /etc/default/hostapd

# Restore dnsmasq configuration to its original state
echo "Restoring dnsmasq configuration..."
sudo mv /etc/dnsmasq.conf.backup /etc/dnsmasq.conf

# Disable IP forwarding (if it was enabled)
echo "Disabling IP forwarding..."
sudo sed -i 's|net.ipv4.ip_forward=1|#net.ipv4.ip_forward=1|' /etc/sysctl.conf
sudo sysctl -p

# Remove NAT (Network Address Translation) rules
echo "Removing NAT (iptables) rules..."
sudo iptables --table nat -D POSTROUTING -o eth0 -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Re-enable interfering services
echo "Re-enabling wpa_supplicant and NetworkManager..."
sudo systemctl enable wpa_supplicant
sudo systemctl enable NetworkManager
sudo systemctl start wpa_supplicant
sudo systemctl start NetworkManager

# Reset wlan0 interface to client mode
echo "Setting wlan0 back to client mode..."
sudo ip link set wlan0 down
sudo iw dev wlan0 set type managed
sudo ip link set wlan0 up

# Restart networking services
echo "Restarting dhcpcd service..."
sudo systemctl restart dhcpcd

echo "Rebooting to apply changes..."
sudo reboot
