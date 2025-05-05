
output "bastion_vm_external_ip" {
  value = module.vm_bastion.external_ip_address
}

output "uc_vm_internal_ip" {
  value = module.vm_uc.internal_ip_address
}

output "nexus_vm_internal_ip" {
  value = module.vm_nexus.internal_ip_address
}

output "windows_internal_ip" {
  value = module.vm_windows.internal_ip_address
}


output "my_current_public_ip" {
  value       = local.my_ip
  description = "Your current public IP address with /32 mask"
}

output "ssh_connection_command" {
  value = "ssh -i ~/.ssh/terraform_20250320 ubuntu@${module.vm_bastion.external_ip_address}"
}

output "rdp_connection_command" {
  value = <<EOT
    Сначала установите SSH-туннель:
    ssh -i ~/.ssh/terraform_20250320 -L 33389:${module.vm_windows.internal_ip_address}:3389 ubuntu@${module.vm_bastion.external_ip_address}

    Затем подключитесь через RDP к localhost:33389
  EOT
}

###############################

output "nexus_url" {
  value = "https://nexus.uc.internal" # Используем HTTPS и порт 443 (nginx будет проксировать 8081)
}

output "dns_nexus_fqdn" {
  value = "nexus.uc.internal" # Без точки в конце для удобства копирования
}

output "nexus_admin_password_command" {
  value = <<EOT
    Получить пароль админа Nexus:
    ssh -i ~/.ssh/terraform_20250320 -J ubuntu@${module.vm_bastion.external_ip_address} ubuntu@${module.vm_nexus.internal_ip_address} \
    'sudo docker exec nexus cat /nexus-data/admin.password'
  EOT
}


