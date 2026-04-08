locals {
  spaces_bucket_name = var.emby_bucket_name
}

resource "digitalocean_spaces_bucket" "emby_media" {
  name   = local.spaces_bucket_name
  region = var.spaces_bucket_region
  acl    = "private"
}

resource "digitalocean_spaces_key" "emby_mount" {
  name = var.spaces_key_name

  grant {
    bucket     = digitalocean_spaces_bucket.emby_media.name
    permission = "readwrite"
  }
}
