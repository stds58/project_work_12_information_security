terraform {
  required_version = ">= 1.10.5" # Указываем минимальную версию Terraform
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.138.0" # Фиксируем версию провайдера
    }
  }
}