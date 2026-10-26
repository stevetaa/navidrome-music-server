#!/usr/bin/env python3
"""Show what you're playing on Navidrome as a Discord status.

Runs on your Mac. Polls Navidrome's Subsonic getNowPlaying endpoint and sets
Rich Presence through the Discord desktop app's normal local connection.
It never uses your Discord token, so it stays within Discord's rules.

Setup: see README.md in this folder.
"""
import hashlib
import json
import os
import secrets
import sys
import time
import urllib.parse
import urllib.request

from pypresence import Presence

try:  # newer pypresence versions can show "Listening to"
    from pypresence import ActivityType
except ImportError:
    ActivityType = None

URL = os.environ.get("NAVIDROME_URL", "").rstrip("/")
USER = os.environ.get("NAVIDROME_USER", "")
PASSWORD = os.environ.get("NAVIDROME_PASSWORD", "")
CLIENT_ID = os.environ.get("DISCORD_CLIENT_ID", "")
POLL_SECONDS = int(os.environ.get("POLL_SECONDS", "15"))
# A track still listed as "now playing" after this long is treated as stale.
STALE_SECONDS = int(os.environ.get("STALE_SECONDS", "600"))


def require_config():
    missing = [n for n, v in [("NAVIDROME_URL", URL), ("NAVIDROME_USER", USER),
                              ("NAVIDROME_PASSWORD", PASSWORD),
                              ("DISCORD_CLIENT_ID", CLIENT_ID)] if not v]
    if missing:
        sys.exit("Set these environment variables first: " + ", ".join(missing))


def now_playing():
    """Return (title, artist, album, track_id) for this user's current track, or None."""
    salt = secrets.token_hex(6)
    token = hashlib.md5((PASSWORD + salt).encode()).hexdigest()
    query = urllib.parse.urlencode({
        "u": USER, "t": token, "s": salt, "v": "1.16.1",
        "c": "discord-presence", "f": "json",
    })
    with urllib.request.urlopen(f"{URL}/rest/getNowPlaying.view?{query}", timeout=10) as r:
        body = json.load(r)["subsonic-response"]
    if body.get("status") != "ok":
        raise RuntimeError(body.get("error", {}).get("message", "Subsonic error"))
    entries = body.get("nowPlaying", {}).get("entry", [])
    if isinstance(entries, dict):
        entries = [entries]
    mine = [e for e in entries if e.get("username") == USER
            and e.get("minutesAgo", 0) * 60 < STALE_SECONDS]
    if not mine:
        return None
    e = min(mine, key=lambda x: x.get("minutesAgo", 0))
    return e.get("title", "Unknown"), e.get("artist", "Unknown"), e.get("album", ""), e.get("id")


def connect():
    while True:
        try:
            rpc = Presence(CLIENT_ID)
            rpc.connect()
            print("Connected to Discord.")
            return rpc
        except Exception:
            print("Discord isn't running yet, retrying in 15s...")
            time.sleep(15)


def main():
    require_config()
    rpc = connect()
    current_id, started = None, None
    while True:
        try:
            track = now_playing()
            if track is None:
                if current_id is not None:
                    rpc.clear()
                    current_id = None
                    print("Nothing playing, status cleared.")
            else:
                title, artist, album, track_id = track
                if track_id != current_id:
                    current_id, started = track_id, int(time.time())
                    kwargs = dict(details=title[:128], state=f"by {artist}"[:128],
                                  large_text=(album or "Navidrome")[:128], start=started)
                    if ActivityType is not None:
                        kwargs["activity_type"] = ActivityType.LISTENING
                    try:
                        rpc.update(**kwargs)
                    except TypeError:
                        kwargs.pop("activity_type", None)
                        rpc.update(**kwargs)
                    print(f"Now playing: {title} - {artist}")
        except (OSError, RuntimeError, KeyError, ValueError) as err:
            print(f"Problem: {err}")
            if "pipe" in str(err).lower() or isinstance(err, BrokenPipeError):
                rpc = connect()
                current_id = None
        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\nStopped.")
