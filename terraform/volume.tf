resource "digitalocean_volume" "docker_data" {
  region                  = "sfo2"
  name                    = "docker-data-volume"
  size                    = 50
  initial_filesystem_type = "ext4"
  description             = "Persistent storage for Docker data"
}

resource "digitalocean_volume_attachment" "docker_data" {
  droplet_id = digitalocean_droplet.www-1.id
  volume_id  = digitalocean_volume.docker_data.id
}
