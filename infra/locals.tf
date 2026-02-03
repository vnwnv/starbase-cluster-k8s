locals {
  checksum_filename_match = basename(var.image_download_config.url)
  checksum_body_raw       = replace(data.http.image_checksum.response_body, "\r", "")
  checksum_lines          = split("\n", trimspace(local.checksum_body_raw))
  # grep
  checksum_matching_lines = [for line in local.checksum_lines : trimspace(line) if line != "" && strcontains(line, local.checksum_filename_match)]
  # compatible with single line
  checksum_line = length(local.checksum_matching_lines) > 0 ? local.checksum_matching_lines[0] : trimspace(local.checksum_body_raw)

  checksum = try(
    regex("^[0-9a-f]+", local.checksum_line),
    try(split(" ", local.checksum_line)[0], regex("^[0-9a-f]+", data.http.image_checksum.response_body))
  )
  vm_types = keys(var.vms)

  # translate to { "vm_name": { type, vm, fqdn } } structure from var.vms 
  all_vms = merge(
    [for vm_type, config in var.vms :
      {
        for vm_name, fqdn in config.nodes :
        vm_name => {
          type = vm_type,
          fqdn = fqdn
        }
      }
      if config != null
    ]...
  )

  vm_random_minutes = {
    for key, attr in local.all_vms :
    key => random_shuffle.random_minutes[key].result[0]
  }

  reboot_window = {
    for key, attr in local.all_vms :
    key => format("%02d:%02d",
      var.cloud_init_config.template.reboot_slots[
        index(keys(local.all_vms), key) % length(var.cloud_init_config.template.reboot_slots)
      ],
      local.vm_random_minutes[key]
    )
  }
}
