
variable "token" {
  type    = string
  default = ""
}

variable "cloud_id" {
  type    = string
  default = ""
}

variable "folder_id" {
  description = "ID каталога в Yandex Cloud"
  type        = string
  default     = ""
}

variable "zone" {
  description = "Use specific availability zone"
  type        = string
  default     = "ru-central1-a"
}




variable "instance_name" {
  description = "Имя_инстанса"
  type        = string
  default     = "vm"
}

variable "platform_id" {
  description = "Тип платформы (например, standard-v2)"
  type        = string
  default     = "standard-v3"
}

variable "cores" {
  description = "Количество vCPU"
  type        = number
  default     = 2
}

variable "memory" {
  description = "RAM в ГБ"
  type        = number
  default     = 2
}

variable "core_fraction" {
  description = "Гарантированная доля CPU в процентах"
  type        = number
  default     = 100
}

variable "image_id" {
  description = "Образ ОС"
  type        = string
  default     = "image_id"
}

variable "disk_size" {
  description = "Размер загрузочного диска в ГБ"
  type        = number
  default     = 20
}

variable "disk_type" {
  description = "Тип загрузочного диска"
  type        = string
  default     = "network-ssd"
}

variable "subnet_id" {
  description = "ID подсети"
  type        = string
  default     = "subnet_id"
}

variable "route_table_id" {
  type        = string
  description = "ID of the route table to associate"
  default     = null
}

variable "nat" {
  description = "ID подсети"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "ID групп безопасности"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "Metadata to pass to the instance."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels to assign to the instance."
  type        = map(string)
  default     = {}
}

variable "network_name" {
  description = "Имя сети"
  type        = string
  default     = "network"
}

variable "network_id" {
  description = "ID of the VPC network."
  type        = string
  default     = "network_id"
}

variable "security_group_name" {
  description = "имя группы безопасности"
  type        = string
  default     = "sg"
}

variable "ingress_rules" {
  description = <<EOT
  Список правил для входящего трафика (ingress) в группе безопасности
  - protocol: протокол (tcp, udp, icmp и т.д.)
  - port: номер порта
  - v4_cidr_blocks: список IPv4-подсетей в формате CIDR
  EOT
  type = list(object({
    protocol       = string
    port           = optional(number)
    v4_cidr_blocks = list(string)
  }))
  default = [
    {
      protocol       = "any"
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "egress_rules" {
  description = "Список правил для исходящего трафика (egress) в группе безопасности"
  type = list(object({
    protocol       = string
    port           = optional(number)
    v4_cidr_blocks = list(string)
  }))
  default = [
    {
      protocol       = "any"
      v4_cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "subnet_name" {
  description = "Имя подсети"
  type        = string
  default     = "subnet"
}

variable "v4_cidr_blocks" {
  description = "список IPv4-подсетей в формате CIDR"
  type        = list(string)
  default     = []
}