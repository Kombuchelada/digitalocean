resource "digitalocean_droplet" "www-1" {
  image    = "ubuntu-24-04-x64"
  name     = "www-1"
  region   = "sfo2"
  size     = "s-1vcpu-512mb-10gb"
  ssh_keys = [data.digitalocean_ssh_key.xXMacbookXx.id]
  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

