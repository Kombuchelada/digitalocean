resource "digitalocean_firewall" "www-1" {
  name = "www-1-firewall"

  droplet_ids = [digitalocean_droplet.www-1.id]

  # Allow SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTP
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow HTTPS
  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Satisfactory server - Game port (UDP)
  inbound_rule {
    protocol         = "udp"
    port_range       = "7777"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Satisfactory server - API port (TCP)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "7777"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Satisfactory server - Query port
  inbound_rule {
    protocol         = "udp"
    port_range       = "15000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Satisfactory server - Beacon port
  inbound_rule {
    protocol         = "udp"
    port_range       = "15777"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
