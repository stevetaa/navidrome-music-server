#!/usr/bin/env bash
# Loads the saved settings and starts the presence script. Used by the background service.
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
set -a
# shellcheck disable=SC1091
source "$HOME/.config/navidrome-presence.env"
set +a
exec "$DIR/.venv/bin/python" "$DIR/presence.py"
