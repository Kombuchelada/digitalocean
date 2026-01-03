resource "digitalocean_droplet" "www-1" {
  image      = "ubuntu-24-04-x64"
  name       = "www-1"
  region     = "sfo2"
  size       = "s-1vcpu-2gb"
  ssh_keys   = [data.digitalocean_ssh_key.xXMacbookXx.id]
  monitoring = true

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
