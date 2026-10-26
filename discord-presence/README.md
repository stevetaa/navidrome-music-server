# Discord presence for Navidrome

Shows the song you're playing on Navidrome (phone or Mac) as your Discord status.

It runs on your Mac, asks Navidrome what you're playing, and tells the Discord
desktop app through its normal local Rich Presence connection. Your Discord token
is never used, and nothing extra runs on the server.

## Setup

1. Go to <https://discord.com/developers/applications>, click **New Application**
   and name it (the name shows as "Listening to ..."). Copy the **Application ID**.
2. Install the dependency:

   ```bash
   cd discord-presence
   python3 -m venv .venv && source .venv/bin/activate
   pip install -r requirements.txt
   ```

3. Run it with your details (keep the password out of any file in the repo):

   ```bash
   export NAVIDROME_URL="https://your-vm.your-tailnet.ts.net"
   export NAVIDROME_USER="your-navidrome-username"
   export NAVIDROME_PASSWORD="your-navidrome-password"
   export DISCORD_CLIENT_ID="the-application-id"
   python presence.py
   ```

4. Keep the Discord desktop app open, and Tailscale on. Play a song on your phone;
   within about 15 seconds it appears on your profile.

In Discord, **Settings > Activity Privacy** must have activity sharing switched on.

## Limits

- Needs the Mac on, Discord open and Tailscale connected.
- Shows the song and artist and how long it has been playing, not a live progress bar.
- Pausing doesn't clear the status straight away. It clears about 10 minutes after
  Navidrome stops listing the track (change with `STALE_SECONDS`).
