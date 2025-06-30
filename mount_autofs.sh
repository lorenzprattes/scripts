#!/bin/bash

# inspiriert vom minmos autofs script danke meista

# Check if running as root, exit if not
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root" >&2
  exit 1
fi

#check if fstab entry already exists, if so, remove it
MOUNT_POINT="/mnt/nfs/media"
SERVER_IP="192.168.178.72"
NFS_PATH="/srv/media"

BASE_DIR=$(dirname "$MOUNT_POINT")
FILENAME=$(basename "$MOUNT_POINT")

if grep -q "$MOUNT_POINT" /etc/fstab; then
  echo "Removing existing fstab entry..."
  sed -i "\|$MOUNT_POINT|d" /etc/fstab
fi

# Update package list and install autofs if it's not already installed
if ! command -v autofs &> /dev/null; then
    echo "Installing autofs..."
    apt-get install -y autofs
else
    echo "autofs is already installed."
fi

# Create mountpoint directory if they don't exist
if [ ! -d "$MOUNT_POINT" ]; then
  echo "Creating mountpoint directory..."
  mkdir -p "$MOUNT_POINT"
fi

# Create and fill files
echo "Creating and filling files..."
printf "\n$BASE_DIR /etc/auto.nfsdb --timeout=180" >> /etc/auto.master
echo "$FILENAME -fstype=nfs4,rw,soft,intr $SERVER_IP:$NFS_PATH" > /etc/auto.nfsdb

# Print completion message
echo "starting autofs"
sudo /etc/init.d/autofs start
sudo systemctl enable autofs.service
echo "Script completed successfully."