
output "internal_ip_address_vm1" {
  value = module.vm1.internal_ip_address
}

output "external_ip_address_vm1" {
  value = module.vm1.external_ip_address
}

output "internal_ip_address_vm_uc" {
  value = module.vm_uc.internal_ip_address
}

output "external_ip_address_vm_uc" {
  value = module.vm_uc.external_ip_address
}

output "dns_artifactory_fqdn" {
  value = yandex_dns_recordset.artifactory.name
}


