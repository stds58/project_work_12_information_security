
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

variable "zone" {
  description = "зона доступности"
  type        = string
  default     = "ru-central1-a"
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
