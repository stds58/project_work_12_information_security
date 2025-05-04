variable "network_id" {
  description = "ID of the VPC network."
  type        = string
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