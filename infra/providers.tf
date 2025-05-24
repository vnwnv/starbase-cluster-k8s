provider "proxmox" {
  endpoint  = var.cloud_provider.endpoint
  api_token = var.cloud_provider.api_token
  insecure  = var.cloud_provider.insecure
  ssh {
    agent       = var.cloud_provider.ssh.agent
    username    = var.cloud_provider.ssh.username
    private_key = file(var.cloud_provider.ssh.private_key)
  }
}
