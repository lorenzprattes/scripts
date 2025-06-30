#!/bin/bash
#
# Autofs configuration script to set up two NFS mounts:
#   1. /mnt/usenet -> 192.168.178.92:/mnt/usenet
#   2. /mnt/nfs/media -> 192.168.178.72:/srv/media
#
# Make sure that /srv/media is exported on 192.168.178.72 with the desired NFS
# export options, e.g. in /etc/exports on the server:
#    /srv/media  *(insecure,no_root_squash,rw,nohide,no_subtree_check)

# ------------------------------------------------------------------------------
# 1. Check if running as root
# ------------------------------------------------------------------------------
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# ------------------------------------------------------------------------------
# 2. Define the NFS mounts you want autofs to manage
#    The array key is the local mount point
#    The array value is the 'server:/path' string
# ------------------------------------------------------------------------------
declare -A NFS_MOUNTS
NFS_MOUNTS["/mnt/usenet"]="192.168.178.92:/mnt/usenet"
NFS_MOUNTS["/mnt/nfs/media"]="192.168.178.72:/srv/media"

# ------------------------------------------------------------------------------
# 3. Install autofs if not already installed
# ------------------------------------------------------------------------------
if ! command -v automount &> /dev/null; then
  echo "Installing autofs..."
  apt-get update
  apt-get install -y autofs
else
  echo "autofs is already installed."
fi

# ------------------------------------------------------------------------------
# 4. Remove any old direct-map entry from /etc/auto.master
#    We assume you are using a "direct map" (the /- syntax)
# ------------------------------------------------------------------------------
sed -i "\|/etc/auto.nfsdb|d" /etc/auto.master

# ------------------------------------------------------------------------------
# 5. Add a fresh entry for your direct map to /etc/auto.master
#    Timeout of 180 seconds (adjust to your liking)
# ------------------------------------------------------------------------------
echo "/-   /etc/auto.nfsdb  --timeout=180" >> /etc/auto.master

# ------------------------------------------------------------------------------
# 6. Create or overwrite /etc/auto.nfsdb with your direct map entries
# ------------------------------------------------------------------------------
echo "# Autofs NFS direct map" > /etc/auto.nfsdb

for MOUNT_POINT in "${!NFS_MOUNTS[@]}"; do
  NFS_PATH="${NFS_MOUNTS[$MOUNT_POINT]}"

  # Ensure the mountpoint directory exists
  if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating directory: $MOUNT_POINT"
    mkdir -p "$MOUNT_POINT"
  fi

  # Append a direct-map entry to /etc/auto.nfsdb

  echo "$MOUNT_POINT -fstype=nfs4,rw,soft $NFS_PATH" >> /etc/auto.nfsdb
done

# ------------------------------------------------------------------------------
# 7. Restart and enable autofs to apply changes
# ------------------------------------------------------------------------------
echo "Restarting autofs..."
systemctl restart autofs
systemctl enable autofs

echo "NFS autofs configuration is complete."