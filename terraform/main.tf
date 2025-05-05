
module "network" {
  source = "./modules/network"

  name = "uc_network"
}

module "subnetwork" {
  source = "./modules/subnet"

  subnet_name    = "uc_subnetwork"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = module.network.network_id
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

data "yandex_compute_image" "windows" {
  family = "fotonsrv-kosmosvm2022"
}


############################## бастион
data "http" "my_ip" {
  url = "https://ifconfig.me/ip"
}

locals {
  my_ip = "${chomp(data.http.my_ip.response_body)}/32" # chomp() удаляет лишние переносы строк
}

module "sg_bastion" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-bastion"
  ingress_rules = [
    {
      description    = "SSH from my IP"
      protocol       = "tcp"
      port           = 22
      v4_cidr_blocks = [local.my_ip]
      #v4_cidr_blocks = ["<YOUR_PUBLIC_IP>/32"] # Замените на ваш IP
    }
  ]
}

module "vm_bastion" {
  source = "./modules/instance"

  name               = "bastion"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 2
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 20
  disk_type          = "network-ssd"
  subnet_id          = module.subnetwork.subnet_id
  nat                = true # Публичный IP
  security_group_ids = [module.sg_bastion.security_group_id]

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/terraform_20250320.pub")}"
  }

  labels = {
    environment = "bastion-dev"
    terraform   = "true"
    role        = "bastion"
  }
}


############################## УЦ
module "sg_vm_uc" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-vm-uc"
  ingress_rules = [
    {
      protocol       = "tcp"
      description    = "SSH access"
      port           = 22
      v4_cidr_blocks = ["${module.vm_bastion.internal_ip_address}/32"]
    }
  ]
}

module "vm_uc" {
  source = "./modules/instance"

  name               = "vm-uc"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 2
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 20
  disk_type          = "network-ssd"
  subnet_id          = module.subnetwork.subnet_id
  security_group_ids = [module.sg_vm_uc.security_group_id]
  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/terraform_20250320.pub")}"
    user-data = <<-EOF
      #!/bin/bash
      # Установка базовых пакетов
      apt-get update
      apt-get install -y openssl ca-certificates python3 docker.io

      # Создание директории для сертификатов
      mkdir -p /etc/ssl/uc
      chmod 700 /etc/ssl/uc

      # Генерация Root CA (если не существует)
      if [ ! -f /etc/ssl/uc/rootCA.key ]; then
        openssl genrsa -out /etc/ssl/uc/rootCA.key 4096
        openssl req -x509 -new -nodes -key /etc/ssl/uc/rootCA.key \
          -sha256 -days 3650 -out /etc/ssl/uc/rootCA.crt \
          -subj "/C=RU/ST=Moscow/L=Moscow/O=MyCompany/OU=IT/CN=UC Root CA"
      fi

      # Генерация сертификата для Nexus
      openssl genrsa -out /etc/ssl/uc/nexus.key 2048
      openssl req -new -key /etc/ssl/uc/nexus.key \
        -out /etc/ssl/uc/nexus.csr \
        -subj "/C=RU/ST=Moscow/L=Moscow/O=MyCompany/OU=IT/CN=nexus.uc.internal"

      openssl x509 -req -in /etc/ssl/uc/nexus.csr \
        -CA /etc/ssl/uc/rootCA.crt -CAkey /etc/ssl/uc/rootCA.key -CAcreateserial \
        -out /etc/ssl/uc/nexus.crt -days 365 -sha256

      # Запуск HTTP-сервера для раздачи сертификатов
      docker run -d --name cert-server -p 80:80 \
        -v /etc/ssl/uc:/usr/share/nginx/html:ro nginx:alpine
    EOF
  }

  labels = {
    environment = "uc-dev"
    terraform   = "true"
    role        = "uc"
  }
}

############################## nexus
module "sg_nexus" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-nexus"
  ingress_rules = [
    {
      protocol       = "tcp"
      description    = "SSH access"
      port           = 22
      v4_cidr_blocks = ["${module.vm_bastion.internal_ip_address}/32"]
    },
    {
      protocol       = "tcp"
      description    = "HTTP access"
      port           = 80
      v4_cidr_blocks = ["192.168.10.0/24"]
    },
    {
      protocol       = "tcp"
      description    = "HTTPS access"
      port           = 443
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
  ]
}

module "vm_nexus" {
  source = "./modules/instance"

  name               = "vm-nexus"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 4
  memory             = 8
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 50
  disk_type          = "network-ssd"
  subnet_id          = module.subnetwork.subnet_id
  security_group_ids = [module.sg_nexus.security_group_id]
  metadata = {
    ssh-keys  = "ubuntu:${file("~/.ssh/terraform_20250320.pub")}"
    user-data = <<-EOF
      #!/bin/bash
      # Установка зависимостей
      apt-get update
      apt-get install -y apt-transport-https ca-certificates curl software-properties-common nginx

      # Установка Docker
      curl -fsSL https://get.docker.com | sh
      usermod -aG docker ubuntu

      # Скачивание сертификатов с УЦ
      mkdir -p /etc/ssl/nexus
      curl -o /etc/ssl/nexus/rootCA.crt http://${module.vm_uc.internal_ip_address}/rootCA.crt
      curl -o /etc/ssl/nexus/nexus.crt http://${module.vm_uc.internal_ip_address}/nexus.crt
      curl -o /etc/ssl/nexus/nexus.key http://${module.vm_uc.internal_ip_address}/nexus.key
      chmod 600 /etc/ssl/nexus/*

      # Запуск Nexus в Docker
      docker run -d \
        --name nexus \
        -p 8081:8081 \
        -v /nexus-data:/nexus-data \
        sonatype/nexus3

      # Настройка Nginx как reverse proxy с SSL
      cat > /etc/nginx/sites-available/nexus <<'NGINX'
      server {
          listen 80;
          server_name nexus.uc.internal;
          return 301 https://$host$request_uri;
      }

      server {
          listen 443 ssl;
          server_name nexus.uc.internal;

          ssl_certificate /etc/ssl/nexus/nexus.crt;
          ssl_certificate_key /etc/ssl/nexus/nexus.key;
          ssl_trusted_certificate /etc/ssl/nexus/rootCA.crt;

          location / {
              proxy_pass http://localhost:8081;
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
          }
      }
      NGINX

      # Активация конфига Nginx
      ln -sf /etc/nginx/sites-available/nexus /etc/nginx/sites-enabled/
      systemctl restart nginx

      # Добавление записи в локальный hosts (на случай задержки DNS)
      echo "127.0.0.1 nexus.uc.internal" >> /etc/hosts
    EOF
  }

  labels = {
    environment = "nexus-dev"
    terraform   = "true"
    role        = "nexus"
  }
}

#Проверка работы
#ssh -i ~/.ssh/terraform_20250320 -J ubuntu@${module.vm_bastion.external_ip} ubuntu@${module.vm_nexus.internal_ip} "
#  docker ps -a
#  sudo systemctl status nginx
#  curl -kI https://nexus.uc.internal
#"

############################## windows

module "sg_windows" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-windows"
  ingress_rules = [
    {
      description    = "RDP from Bastion"
      protocol       = "tcp"
      port           = 3389
      v4_cidr_blocks = ["${module.vm_bastion.internal_ip_address}/32"]
    }
  ]
}

module "vm_windows" {
  source = "./modules/instance"

  name               = "windows-test"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 4
  core_fraction      = 100
  image_id           = data.yandex_compute_image.windows.id
  disk_size          = 50
  disk_type          = "network-ssd"
  subnet_id          = module.subnetwork.subnet_id
  security_group_ids = [module.sg_windows.security_group_id]

  metadata = {
    user-data = <<-EOF
      #ps1
      # Настройка RDP
      Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
      Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

      # Скачивание и установка Root CA
      $caUrl = "http://${module.vm_uc.internal_ip_address}/rootCA.crt"
      $caPath = "$env:TEMP\rootCA.crt"

      try {
        Invoke-WebRequest -Uri $caUrl -OutFile $caPath -ErrorAction Stop
        Import-Certificate -FilePath $caPath -CertStoreLocation Cert:\LocalMachine\Root -ErrorAction Stop
        Write-Output "[SUCCESS] Root CA installed successfully"
      } catch {
        Write-Output "[ERROR] Failed to install Root CA: $_"
      }

      # Добавление записи в hosts файл
      $hostsEntry = "${module.vm_nexus.internal_ip_address} nexus.uc.internal"
      if (-not (Select-String -Path $env:windir\System32\drivers\etc\hosts -Pattern "nexus.uc.internal" -Quiet)) {
        Add-Content -Path $env:windir\System32\drivers\etc\hosts -Value "`n$hostsEntry" -Force
      }

      # Установка Chrome для тестирования (опционально)
      $chromeInstaller = "$env:TEMP\chrome_installer.exe"
      if (-not (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe")) {
        Invoke-WebRequest "https://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $chromeInstaller
        Start-Process -FilePath $chromeInstaller -Args "/silent /install" -Wait
      }
    EOF
  }

  labels = {
    environment = "windows-dev"
    terraform   = "true"
    role        = "windows"
  }
}

##############################

# Создаем внутреннюю DNS-зону
resource "yandex_dns_zone" "internal_zone" {
  name             = "internal-uc-zone"
  description      = "Internal DNS zone for UC and Nexus"
  zone             = "uc.internal."
  public           = false
  private_networks = [module.network.network_id]
}

# Добавляем запись для Nexus
resource "yandex_dns_recordset" "nexus" {
  zone_id = yandex_dns_zone.internal_zone.id
  name    = "nexus.uc.internal."
  type    = "A"
  ttl     = 600
  data    = [module.vm_nexus.internal_ip_address]
}

##############################







