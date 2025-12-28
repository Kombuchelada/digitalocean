output "www_1_ip" {
  description = "IPv4 address of the www-1 droplet"
  value       = digitalocean_droplet.www-1.ipv4_address
}
