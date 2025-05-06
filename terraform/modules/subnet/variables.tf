
variable "subnet_name" {
  description = "Имя подсети"
  type        = string
  default     = "subnet"
}

variable "zone" {
  description = "Use specific availability zone"
  type        = string
  default     = "ru-central1-a"
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "v4_cidr_blocks" {
  description = "список IPv4-подсетей в формате CIDR"
  type        = list(string)
  default     = []
}

variable "route_table_id" {
  type        = string
  description = "ID of the route table to associate"
  default     = null
}
