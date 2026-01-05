resource "digitalocean_droplet" "www-1" {
  image      = "ubuntu-24-04-x64"
  name       = "www-1"
  region     = "sfo2"
  size       = "s-2vcpu-4gb"
  ssh_keys   = [data.digitalocean_ssh_key.xXMacbookXx.id]
  monitoring = true

  # Cloud-init script to create a persistent 4G swapfile and mild sysctl tuning
  user_data = <<-EOT
    #cloud-config
    runcmd:
      - |
        set -euo pipefail
        SWAPFILE="/swapfile"
        if [ ! -f "${SWAPFILE}" ]; then
          # Try fallocate first, fall back to dd if needed
          fallocate -l 4G "${SWAPFILE}" || dd if=/dev/zero of="${SWAPFILE}" bs=1M count=4096 status=progress
          chmod 600 "${SWAPFILE}"
          mkswap "${SWAPFILE}"
        fi
        swapon "${SWAPFILE}" || true
        grep -q "^/swapfile " /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
        cat <<'EOF' > /etc/sysctl.d/99-swap-tuning.conf
        vm.swappiness = 10
        vm.vfs_cache_pressure = 50
        EOF
        sysctl -p /etc/sysctl.d/99-swap-tuning.conf || true
  EOT

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }
}

resource "digitalocean_floating_ip" "www-1" {
  region = digitalocean_droplet.www-1.region
}

resource "digitalocean_floating_ip_assignment" "www-1" {
  ip_address = digitalocean_floating_ip.www-1.ip_address
  droplet_id = digitalocean_droplet.www-1.id
}
