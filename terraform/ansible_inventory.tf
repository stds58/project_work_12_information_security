locals {
  depends_on = [
    module.vm_bastion,
    module.vm_uc,
    module.vm_nexus,
    module.vm_windows
  ]

  inventory_template = templatefile(
    "${path.module}/inventory.tpl", {
      vm_bastion_ip = module.vm_bastion.external_ip_address
      vm_uc_ip      = module.vm_uc.internal_ip_address
      vm_nexus_ip   = module.vm_nexus.internal_ip_address
      vm_windows_ip = module.vm_windows.internal_ip_address
    }
  )
}
