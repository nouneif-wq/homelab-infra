# providers.tf
terraform {
  required_providers {
    proxmox = { source = "bpg/proxmox" }
  }
}

variable "pm_api_token" {
  type      = string
  sensitive = true
}

provider "proxmox" {
  endpoint  = "https://192.168.1.11:8006/"
  api_token = var.pm_api_token
  insecure  = true   # Proxmox uses a self-signed certificate
}
