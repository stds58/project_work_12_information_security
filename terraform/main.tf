
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  network_id = module.network.network_id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

module "network" {
  source = "./modules/network"

  network_name = "uc_network"
}

module "subnetwork" {
  source = "./modules/subnet"

  subnet_name    = "uc_subnetwork"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = module.network.network_id
  route_table_id = yandex_vpc_route_table.rt.id
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

  instance_name               = "bastion"
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
    },
    {
      protocol       = "tcp"
      description    = "HTTP access for certificates"
      port           = 80
      v4_cidr_blocks = ["192.168.10.0/24"] # вся внутренняя сеть
    }
  ]
}

module "vm_uc" {
  source = "./modules/instance"

  instance_name               = "vm-uc"
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

  instance_name               = "vm-nexus"
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

############################## Linux RDP VM

module "sg_linux_rdp" {
  source = "./modules/security-groups"

  network_id          = module.network.network_id
  security_group_name = "sg-linux-rdp"
  ingress_rules = [
    {
      description    = "SSH from Bastion"
      protocol       = "tcp"
      port           = 22
      v4_cidr_blocks = ["${module.vm_bastion.internal_ip_address}/32"]
    },
    {
      description    = "RDP from Bastion"
      protocol       = "tcp"
      port           = 3390
      v4_cidr_blocks = ["${module.vm_bastion.internal_ip_address}/32"]
    },
    {
      description    = "HTTP access for testing"
      protocol       = "tcp"
      port           = 80
      v4_cidr_blocks = ["192.168.10.0/24"]
    }
  ]
}

module "vm_linux_rdp" {
  source = "./modules/instance"

  instance_name      = "linux-test"
  platform_id        = "standard-v3"
  zone               = "ru-central1-a"
  cores              = 2
  memory             = 4
  core_fraction      = 100
  image_id           = data.yandex_compute_image.ubuntu.id
  disk_size          = 20
  disk_type          = "network-ssd"
  subnet_id          = module.subnetwork.subnet_id
  security_group_ids = [module.sg_linux_rdp.security_group_id]

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/terraform_20250320.pub")}"
    user-data = <<-EOF
      #!/bin/bash
      #
      echo "ubuntu:your_password" | chpasswd
      apt-get update
      apt-get install -y xfce4 xrdp chromium-browser
      sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
      echo "xfce4-session" > /home/ubuntu/.xsession
      chown ubuntu:ubuntu /home/ubuntu/.xsession

      # Установка XRDP и GUI
      apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y xfce4 xrdp chromium-browser

      # Настройка XRDP
      sed -i 's/port=3389/port=3390/g' /etc/xrdp/xrdp.ini
      echo "xfce4-session" > /home/ubuntu/.xsession
      chown ubuntu:ubuntu /home/ubuntu/.xsession

      # Добавление записи в hosts
      echo "${module.vm_nexus.internal_ip_address} nexus.example" >> /etc/hosts

      # Запуск сервисов
      systemctl enable xrdp
      systemctl restart xrdp
      EOF
  }

  labels = {
    environment = "test-dev"
    terraform   = "true"
    role        = "test-rdp"
  }
}


##############################
# Создаем внутреннюю DNS-зону
resource "yandex_dns_zone" "internal_zone" {
  name             = "example-zone"
  description      = "Internal DNS zone for UC and Nexus"
  zone             = "example."
  public           = false
  private_networks = [module.network.network_id]
}

# Добавляем запись для Nexus
resource "yandex_dns_recordset" "nexus" {
  zone_id = yandex_dns_zone.internal_zone.id
  name    = "nexus.example."
  type    = "A"
  ttl     = 600
  data    = [module.vm_nexus.internal_ip_address]
}


##############################







