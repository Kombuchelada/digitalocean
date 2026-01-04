resource "digitalocean_record" "CNAME-www" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "www"
  value  = "${var.domain}."
}

resource "digitalocean_record" "wildcard" {
  domain = digitalocean_domain.default.name
  type   = "CNAME"
  name   = "*"
  value  = "${var.domain}."
}
