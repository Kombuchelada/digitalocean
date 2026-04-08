variable "swap_size" {
  description = "Swap size for droplet (e.g., 2G, 4G)."
  type        = string
  default     = "4G"
}

variable "emby_bucket_name" {
  description = "Name for the DigitalOcean Spaces bucket used by Emby media storage."
  type        = string
  default     = "emby-media"
}

variable "spaces_bucket_region" {
  description = "DigitalOcean Spaces region for Emby media storage."
  type        = string
  default     = "sfo2"
}

variable "spaces_key_name" {
  description = "Name of the DigitalOcean Spaces access key created for the Emby mount."
  type        = string
  default     = "emby-spaces-key"
}
