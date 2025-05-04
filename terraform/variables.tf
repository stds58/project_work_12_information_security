
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


