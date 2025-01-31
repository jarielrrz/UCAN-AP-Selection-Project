#!/bin/bash

# Function to display current configuration
show_current_config() {
  if [ -f /etc/hostapd/hostapd.conf ]; then
    echo "Current hostapd Configuration:"
    echo "--------------------------------"
    cat /etc/hostapd/hostapd.conf
    echo "--------------------------------"
  else
    echo "No existing hostapd configuration found."
  fi
}

# Function to display usage
usage() {
  echo "Usage: $0 -s <SSID> -m <hw_mode> -c <channel> -p <password>"
  echo "  -s: Set the SSID for the Access Point"
  echo "  -m: Set the hardware mode (e.g., 'g' for 2.4GHz or 'a' for 5GHz)"
  echo "  -c: Set the channel number (e.g., 6)"
  echo "  -p: Set the password (minimum 8 characters)"
  exit 1
}

# Default values
SSID="MyRaspiAP"
HW_MODE="g"
CHANNEL="6"
PASSWORD="defaultpass"

# Show current configuration
echo "Fetching current configuration..."
show_current_config

# Parse arguments
while getopts ":s:m:c:p:" opt; do
  case "${opt}" in
    s) SSID=${OPTARG} ;;
    m) HW_MODE=${OPTARG} ;;
    c) CHANNEL=${OPTARG} ;;
    p) PASSWORD=${OPTARG} ;;
    *) usage ;;
  esac
done

# Check for required arguments
if [[ -z "$SSID" || -z "$HW_MODE" || -z "$CHANNEL" || -z "$PASSWORD" ]]; then
  usage
fi

# Ensure password meets minimum length requirement
if [ ${#PASSWORD} -lt 8 ]; then
  echo "Error: Password must be at least 8 characters long."
  exit 1
fi

# Configure hostapd
echo "Configuring hostapd with SSID: $SSID, hw_mode: $HW_MODE, channel: $CHANNEL"
cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=nl80211
ssid=$SSID
hw_mode=$HW_MODE
channel=$CHANNEL
auth_algs=1
wpa=2
wpa_passphrase=$PASSWORD
wmm_enabled=1
macaddr_acl=0
ignore_broadcast_ssid=0
EOF

# Update the DAEMON_CONF path
echo "Updating /etc/default/hostapd..."
sed -i 's|^#DAEMON_CONF=.*|DAEMON_CONF="/etc/hostapd/hostapd.conf"|' /etc/default/hostapd

# Restart services to apply changes
echo "Restarting hostapd service..."
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl restart hostapd

echo "Access Point configured successfully!"






