# Self-Hosted Music Server

A private, ad-free, Spotify-style music server for music I own. [Navidrome](https://www.navidrome.org/) runs in Docker on an Azure VM, is reachable only over [Tailscale](https://tailscale.com), and is played from an iPhone with a Subsonic-compatible app.

## Architecture

```
Mac (music files)
   |  rsync over SSH (via Tailscale)
   v
Azure VM (Ubuntu 24.04, Spain Central)
   |  Docker -> Navidrome on 127.0.0.1:4533
   |  tailscale serve (HTTPS, tailnet only)
   v
iPhone (Tailscale + Amperfy)
```

No ports are open to the public internet. The only way in, for SSH and for listening, is through the Tailscale network.

## Why these choices

| Decision | Reason |
| --- | --- |
| Navidrome | Lightweight, open source, and speaks the Subsonic API, so many iOS apps work with it |
| Docker Compose | One file describes the whole service, so it is easy to rebuild or move |
| Port bound to `127.0.0.1` | Docker can bypass the host firewall for published ports, so the container is never exposed on a public interface |
| Tailscale instead of open ports | No port forwarding and no public attack surface; `tailscale serve` adds HTTPS |
| Music mounted read-only (`:ro`) | The server can never modify or delete the library |
| SSH key login, non-root user | Basic hardening; public SSH was closed once Tailscale SSH worked |
| 1 GiB B-series VM plus a 1 GiB swap file | Cheap, and enough for a small personal library |
   
## Cost

On an Azure for Students subscription ($100 credit, 12 months):

| Item | Approx. per month |
| --- | --- |
| VM (small B-series) | about $9 |
| 30 GB Standard SSD disk | $2-3 |
| Public IP address | $3-4 |

Roughly $14-16 a month in total, so the credit lasts around six months. Prices are estimates from the Azure portal and change, so check Cost analysis for real numbers. The same setup runs for free on a Mac or Raspberry Pi, because the `docker-compose.yml` is identical.

## Setup summary

Full steps are in [`docs/setup.md`](docs/setup.md).

1. Create an Ubuntu 24.04 VM with SSH key authentication.
2. Update the system, add a swap file, install Docker.
3. Copy `docker-compose.yml` to `~/navidrome/` and run `docker compose up -d`.
4. Upload music with `rsync` into `~/navidrome/music/`.
5. Install Tailscale on the VM, Mac and iPhone, then run `sudo tailscale serve --bg 4533`.
6. Open the printed `https://...ts.net` address, create the admin account, and sign in from the phone app.
7. Delete the public SSH rule in the VM's network security group.

## Problems I ran into

| Problem | Cause | Fix |
| --- | --- | --- |
| VM size "unavailable" | The student subscription only allows a few regions | Read the "Allowed resource deployment regions" policy, then pick a region from that list that offers a small size |
| `RequestDisallowedByAzure` on deploy | I picked a region outside that list | Switched to an allowed region |
| Subscription missing from the VM form | Subscription filter and directory | Created the VM from the correct subscription |
| `Permission denied (publickey)` / passphrase prompt | Reused an old SSH key | Made a dedicated key for this server and reset the VM's key from the portal |
| Phone app "login failed" | Wrong user or password | Checked the same login in Safari, then reset the password in Navidrome |

More detail is in [`docs/troubleshooting.md`](docs/troubleshooting.md).

## Backups

Music originals stay on my Mac. The `data/` folder (users, playlists, play counts) is the part I cannot recreate, and `backup.sh` copies it back to the Mac:

```bash
VM_HOST=<vm-tailscale-address> ./backup.sh
```

## What I would improve next

- [ ] A `setup-vm.sh` script to automate steps 2-3
- [ ] Scheduled backups with cron or launchd
- [ ] An uptime check and a disk-space alert
- [ ] Move to a Raspberry Pi to avoid the monthly hosting cost

## Notes
- No IPs, tailnet names, keys or passwords are stored in this repo. Placeholders such as `<vm-tailscale-address>` need replacing with your own values.
