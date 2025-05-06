
resource "yandex_vpc_subnet" "subnet" {
  name           = var.subnet_name
  zone           = var.zone
  network_id     = var.network_id
  v4_cidr_blocks = var.v4_cidr_blocks
  route_table_id = var.route_table_id
}
