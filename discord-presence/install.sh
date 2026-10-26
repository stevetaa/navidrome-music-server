#!/usr/bin/env bash
# Install the Discord presence script as a background service on macOS.
# It starts at login and restarts itself if it stops.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
CONF="$HOME/.config/navidrome-presence.env"
LABEL="com.navidrome.discord-presence"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/navidrome-presence.log"

echo "Setting up the Python environment..."
[ -x "$DIR/.venv/bin/python" ] || python3 -m venv "$DIR/.venv"
"$DIR/.venv/bin/pip" install -q pypresence

echo
echo "Enter your details (typed values only, no quotes needed)."
read -r -p "Navidrome URL (https://...ts.net): " URL
read -r -p "Navidrome username: " USERNAME
read -r -s -p "Navidrome password (hidden): " PASSWORD; echo
read -r -p "Discord Application ID: " CLIENT_ID

mkdir -p "$HOME/.config" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs"
umask 077
{
  printf 'NAVIDROME_URL=%q\n' "$URL"
  printf 'NAVIDROME_USER=%q\n' "$USERNAME"
  printf 'NAVIDROME_PASSWORD=%q\n' "$PASSWORD"
  printf 'DISCORD_CLIENT_ID=%q\n' "$CLIENT_ID"
} > "$CONF"
chmod 600 "$CONF"

cat > "$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key>
  <array><string>/bin/bash</string><string>$DIR/run.sh</string></array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>$LOG</string>
  <key>StandardErrorPath</key><string>$LOG</string>
</dict>
</plist>
PLISTEOF

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo
echo "Done. It is running now and will start every time you log in."
echo "Log file: $LOG"
echo "Your login details are stored in $CONF (readable only by you, outside the repo)."
