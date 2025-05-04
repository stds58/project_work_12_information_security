
resource "yandex_vpc_security_group" "sg" {
  name       = var.security_group_name
  network_id = var.network_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      protocol       = ingress.value.protocol
      port           = try(ingress.value.port, null)
      v4_cidr_blocks = ingress.value.v4_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      protocol       = egress.value.protocol
      port           = try(egress.value.port, null)
      v4_cidr_blocks = egress.value.v4_cidr_blocks
    }
  }

}
