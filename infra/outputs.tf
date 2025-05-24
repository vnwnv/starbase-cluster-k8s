output "debug_checksum" {
  value = "DEBUG >>> Fetched checksum: '${local.checksum}' (length: ${length(local.checksum)})"
}

output "debug_http_response" {
  value = "DEBUG >>> HTTP response body: '${data.http.microos_checksum.response_body}'"
}

# output "debug_inventory" {
#   value = templatefile("${path.module}/templates/ansible/inventory.tmpl", {
#     vms = var.vms
#   })
# }
