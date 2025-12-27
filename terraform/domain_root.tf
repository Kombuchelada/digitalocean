resource "digitalocean_domain" "default" {
  name       = var.domain
  ip_address = digitalocean_droplet.www-1.ipv4_address
}
