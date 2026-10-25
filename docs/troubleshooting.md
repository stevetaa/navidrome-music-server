# Troubleshooting

| Problem | Likely cause | Fix |
| --- | --- | --- |
| Phone app can't connect | Tailscale is off on the phone | Switch Tailscale on in the app |
| App says "login failed" | Wrong username or password | Try the same login in Safari; reset the password in Navidrome's Users page |
| Certificate or HTTPS error | HTTPS Certificates not enabled, or `http://` typed | Enable HTTPS in the Tailscale admin console DNS page; use `https://` with no port |
| Library is empty | Scan has not run, or wrong folder | `docker compose restart`, then check `ls ~/navidrome/music` |
| Albums have no art or wrong names | Missing file tags | Fix tags with MusicBrainz Picard and rescan |
| `Permission denied (publickey)` | Wrong key, or key not on the VM | Reset the SSH public key from the Azure portal (VM, Help, Reset password) |
| Azure says the VM size is unavailable | Region not allowed or size not offered there | Read the allowed regions policy; try each allowed region with "See all sizes" |
| `RequestDisallowedByAzure` | Region outside the allowed list | Pick a region from the allowed list |
| Disk full | Library larger than the VM disk | Convert FLAC to MP3/AAC, or enlarge the disk (costs credit) |
| Stops working after months | Tailscale key expired | Disable key expiry for the VM in the admin console |
| Port 4533 reachable from outside | `127.0.0.1` removed from the compose file | Restore `127.0.0.1:4533:4533` and run `docker compose up -d` |
| Locked out of SSH after closing port 22 | Tailscale down on the VM | Use **Run command** in the Azure portal, or re-add the port 22 rule |

## Useful commands

```bash
docker compose ps          # is it running?
docker compose logs        # recent logs
docker compose restart     # restart and rescan
df -h /                    # disk space
tailscale status           # Tailscale connections
```

## Updating Navidrome

```bash
cd ~/navidrome && docker compose pull && docker compose up -d
```
