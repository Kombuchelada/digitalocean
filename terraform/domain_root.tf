resource "digitalocean_domain" "default" {
  name       = var.domain
  ip_address = digitalocean_floating_ip.www-1.ip_address
}
