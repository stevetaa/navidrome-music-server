#!/usr/bin/env bash
# Back up Navidrome's data folder (users, playlists, play counts) from the VM to this Mac.
#
# Usage:
#   VM_HOST=<vm-tailscale-address> ./backup.sh
#
# Optional environment variables:
#   VM_USER    SSH user on the VM          (default: azureuser)
#   SSH_KEY    private key to log in with  (default: ~/.ssh/navidrome_key)
#   BACKUP_DIR where to store the backup   (default: ~/navidrome-backup)
set -euo pipefail

: "${VM_HOST:?Set VM_HOST to the Tailscale address of the VM}"
VM_USER="${VM_USER:-azureuser}"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/navidrome_key}"
DEST="${BACKUP_DIR:-$HOME/navidrome-backup}"

mkdir -p "$DEST"

rsync -avh -e "ssh -i ${SSH_KEY}" "${VM_USER}@${VM_HOST}:~/navidrome/data/" "$DEST/"

echo "Backup complete: $DEST ($(date '+%Y-%m-%d %H:%M'))"
