#!/usr/bin/env bash
# Stop the background service and remove it. Add --forget to also delete the saved login details.
set -euo pipefail
LABEL="com.navidrome.discord-presence"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
[ "${1:-}" = "--forget" ] && rm -f "$HOME/.config/navidrome-presence.env"
echo "Stopped and removed."
