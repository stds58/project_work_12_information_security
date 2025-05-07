locals {
  depends_on = [
    module.vm_bastion,
    module.vm_uc,
    module.vm_nexus,
    module.vm_linux_rdp
  ]

  inventory_template = templatefile(
    "${path.module}/inventory.tpl", {
      vm_bastion_ip = module.vm_bastion.external_ip_address
      vm_uc_ip      = module.vm_uc.internal_ip_address
      vm_nexus_ip   = module.vm_nexus.internal_ip_address
      vm_linux_rdp_ip = module.vm_linux_rdp.internal_ip_address
    }
  )
}

resource "local_file" "inventory" {
  depends_on = [
    module.vm_bastion,
    module.vm_uc,
    module.vm_nexus,
    module.vm_linux_rdp
  ]
  content  = local.inventory_template
  filename = "${path.root}/../ansible/inventory"
}
