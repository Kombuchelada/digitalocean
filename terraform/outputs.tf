output "www_1_ip" {
  description = "IPv4 address of the www-1 droplet"
  value       = digitalocean_droplet.www-1.ipv4_address
}

output "spaces_bucket_name" {
  description = "Name of the DigitalOcean Spaces bucket created for Emby media storage."
  value       = digitalocean_spaces_bucket.emby_media.name
}

output "spaces_access_key_id" {
  description = "Access key ID for the DigitalOcean Spaces key used by the Emby mount."
  value       = digitalocean_spaces_key.emby_mount.access_key
}

output "spaces_secret_key" {
  description = "Secret access key for the DigitalOcean Spaces key used by the Emby mount."
  value       = digitalocean_spaces_key.emby_mount.secret_key
  sensitive   = true
}
