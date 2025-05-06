
output "bastion_vm_external_ip" {
  value = module.vm_bastion.external_ip_address
}

output "nexus_vm_internal_ip" {
  value = module.vm_nexus.internal_ip_address
}

output "linux_rdp_internal_ip" {
  value = module.vm_linux_rdp.internal_ip_address
}


output "my_current_public_ip" {
  value       = local.my_ip
  description = "Your current public IP address with /32 mask"
}

output "ssh_connection_command" {
  value = <<EOT
    Подключайтесь к бастиону с флагом -A (Agent Forwarding)
    ssh -A -i ~/.ssh/terraform_20250320 ubuntu@${module.vm_bastion.external_ip_address}
    С бастиона — к внутренней машине:
    ssh ubuntu@${module.vm_linux_rdp.internal_ip_address}

    тунель
    ssh -i ~/.ssh/terraform_20250320 -L 33389:${module.vm_linux_rdp.internal_ip_address}:3390 ubuntu@${module.vm_bastion.external_ip_address} -N -v
    Затем подключитесь через RDP клиент к:
    localhost:33389
    Логин: ubuntu
    Пароль: (укажите при первом подключении)

    Подключитесь к целевой VM через бастион:
    ssh -i ~/.ssh/terraform_20250320 -J ubuntu@${module.vm_bastion.external_ip_address} ubuntu@${module.vm_bastion.external_ip_address}
  EOT
}

output "test_nexus_command" {
  value = <<EOT
    Для тестирования Nexus после подключения по RDP:
    1. Откройте Chromium
    2. Перейдите по адресу: https://nexus.uc.internal
    3. Должен появиться защищенный доступ (зеленый замок)
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

output "proverki" {
  value = <<EOT
    Проверить работу HTTP-сервера на vm-uc
    curl -v http://${module.vm_uc.internal_ip_address}/rootCA.crt
    Если не работает — перезапустите контейнер:
    docker stop cert-server
    docker rm cert-server
    docker run -d --name cert-server -p 80:80 -v /etc/ssl/uc:/usr/share/nginx/html:ro nginx:alpine
    На vm-linux-rdp обновить сертификаты
    sudo update-ca-certificates --fresh
  EOT
}

