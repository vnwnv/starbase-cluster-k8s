terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.73.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.2"
    }
  }
}
