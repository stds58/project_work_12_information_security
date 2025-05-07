
output "bastion_vm_external_ip" {
  value = module.vm_bastion.external_ip_address
}

output "vm_uc_ip" {
  value = module.vm_uc.internal_ip_address
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
    2. Перейдите по адресу: https://nexus.example
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
    #########################################################################
    # установить пароль ubuntu
        ssh -A -i ~/.ssh/terraform_20250320 ubuntu@${module.vm_bastion.external_ip_address}
    С бастиона — к внутренней машине:
        ssh ubuntu@${module.vm_linux_rdp.internal_ip_address}
        sudo su - ubuntu
        sudo passwd ubuntu
    установить пароль ubuntu

    # вручную установить сертификаты
        ssh -A -i ~/.ssh/terraform_20250320 ubuntu@158.160.46.16
    # 2. Скачай ca.crt с vm_uc
        scp -o StrictHostKeyChecking=no ubuntu@192.168.10.24:/etc/ssl/ca.crt /tmp/
    # 3. Отправляем его на vm_linux_rdp
        scp -o StrictHostKeyChecking=no /tmp/ca.crt ubuntu@192.168.10.28:/tmp/
    # 4. Затем подключиcь к vm_linux_rdp
        sudo cp /tmp/ca.crt /usr/local/share/ca-certificates/example-ca.crt
        sudo update-ca-certificates
    # 5. Подключись к линюксу по рдп
         ssh -i ~/.ssh/terraform_20250320 -L 33389:${module.vm_linux_rdp.internal_ip_address}:3390 ubuntu@${module.vm_bastion.external_ip_address} -N -v
         Затем подключитесь через RDP клиент к:
         localhost:33389
         Логин: ubuntu
         Пароль: ubuntu
    # 6. в хромиуме в chrome://settings/certificates импортируй сертификат из /tmp/ca.crt и поставь галки на доверие
    #########################################################################

    # WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!
    # Host key for 192.168.10.24 has changed and you have requested strict checking
    # решение
    wsl ssh-keygen -f ~/.ssh/known_hosts -R 192.168.10.24

    # проверка нексуса
    systemctl status nexus
    journalctl -xeu nexus.service

    # Проверить работу HTTP-сервера на vm-uc
    curl -v http://${module.vm_uc.internal_ip_address}/rootCA.crt
    Если не работает — перезапустите контейнер:
    docker stop cert-server
    docker rm cert-server
    docker run -d --name cert-server -p 80:80 -v /etc/ssl/uc:/usr/share/nginx/html:ro nginx:alpine
    На vm-linux-rdp обновить сертификаты
    sudo update-ca-certificates --fresh
  EOT
}

