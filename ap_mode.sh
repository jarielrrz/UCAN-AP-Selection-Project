#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing necessary packages..."
sudo apt install -y hostapd dnsmasq dhcpcd5 iptables-persistent

echo "Checking and unmasking hostapd service if masked..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd

echo "Configuring dhcpcd..."
cat <<EOF > /etc/dhcpcd.conf
interface wlan0
static ip_address=192.168.4.1/24
nohook wpa_supplicant
EOF

sudo systemctl restart dhcpcd

echo "Configuring hostapd..."
cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=MyRaspiAP
hw_mode=g
channel=6
auth_algs=1
wmm_enabled=0
macaddr_acl=0
ignore_broadcast_ssid=0
EOF

sudo sed -i 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

echo "Configuring dnsmasq..."
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.backup
cat <<EOF > /etc/dnsmasq.conf
interface=wlan0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

echo "Enabling IP forwarding..."
sudo sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
sudo sysctl -p

echo "Setting up NAT (Network Address Translation)..."
sudo iptables --table nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/rules.v4

echo "Stopping interfering services..."
sudo systemctl stop wpa_supplicant NetworkManager
sudo systemctl disable wpa_supplicant NetworkManager

echo "Setting wlan0 to AP mode..."
sudo ip link set wlan0 down
sudo iw dev wlan0 set type __ap
sudo ip link set wlan0 up

echo "Restarting services..."
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq

echo "Rebooting to apply changes..."
sudo reboot








