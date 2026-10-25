# Setup

Commands for building the server from scratch. `(Mac)` means run it on your Mac, `(VM)` means on the Azure VM.

## 1. Create the VM

1. Create an SSH key (Mac):

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/navidrome_key -C "navidrome"
   cat ~/.ssh/navidrome_key.pub
   ```

2. In the Azure portal, check which regions your subscription allows: search for **Policy**, open **Assignments**, then **Allowed resource deployment regions**.
3. Create a VM in one of those regions:
   - Image: Ubuntu Server 24.04 LTS, x64
   - Size: a small B-series size (1 GiB RAM is enough)
   - Authentication: SSH public key, username `azureuser`, paste the public key
   - Availability options: no infrastructure redundancy
   - Disk: Standard SSD
4. Note the VM's public IP.
5. Set a budget alert in Cost Management.

## 2. Prepare the VM

```bash
ssh -i ~/.ssh/navidrome_key azureuser@<vm-public-ip>      # (Mac)
sudo apt update && sudo apt upgrade -y                     # (VM)
```

Add a 1 GiB swap file, because 1 GiB of RAM is tight (VM):

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Install Docker (VM), then log out and back in:

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

Check it works and your user ID is 1000 (VM):

```bash
docker run --rm hello-world
id -u
```

## 3. Run Navidrome

```bash
mkdir -p ~/navidrome/music ~/navidrome/data    # (VM)
cd ~/navidrome
nano docker-compose.yml                         # paste the file from this repo
docker compose up -d
docker compose ps
```

## 4. Upload music

```bash
rsync -avh --progress -e "ssh -i ~/.ssh/navidrome_key" ~/path/to/music/ azureuser@<vm-address>:~/navidrome/music/   # (Mac)
cd ~/navidrome && docker compose restart                                                                             # (VM)
```

Only upload music you have the rights to.

## 5. Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh    # (VM)
sudo tailscale up
```

1. Install Tailscale on your Mac and iPhone and sign in to the same account.
2. In the Tailscale admin console, disable key expiry for the VM.
3. Under DNS, enable MagicDNS and HTTPS Certificates.
4. Publish Navidrome (VM):

   ```bash
   sudo tailscale serve --bg 4533
   ```

5. Open the printed `https://...ts.net` address, create the admin account, and log in from the phone app.

## 6. Close public SSH

1. Find the VM's Tailscale address: `tailscale ip -4` (VM).
2. Check you can log in over it: `ssh -i ~/.ssh/navidrome_key azureuser@<tailscale-address>` (Mac).
3. Only then delete the inbound port 22 rule in the VM's network security group.
4. Confirm the public IP now times out and the Tailscale address still works.

If you lock yourself out, add the port 22 rule again, or use **Run command** on the VM's page in the portal.
