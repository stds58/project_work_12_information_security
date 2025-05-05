<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.5 |
| <a name="requirement_http"></a> [http](#requirement\_http) | ~> 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.0 |
| <a name="requirement_yandex"></a> [yandex](#requirement\_yandex) | 0.138.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_http"></a> [http](#provider\_http) | 3.5.0 |
| <a name="provider_yandex"></a> [yandex](#provider\_yandex) | 0.138.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_sg_bastion"></a> [sg\_bastion](#module\_sg\_bastion) | ./modules/security-groups | n/a |
| <a name="module_sg_nexus"></a> [sg\_nexus](#module\_sg\_nexus) | ./modules/security-groups | n/a |
| <a name="module_sg_vm_uc"></a> [sg\_vm\_uc](#module\_sg\_vm\_uc) | ./modules/security-groups | n/a |
| <a name="module_sg_windows"></a> [sg\_windows](#module\_sg\_windows) | ./modules/security-groups | n/a |
| <a name="module_subnetwork"></a> [subnetwork](#module\_subnetwork) | ./modules/subnet | n/a |
| <a name="module_vm_bastion"></a> [vm\_bastion](#module\_vm\_bastion) | ./modules/instance | n/a |
| <a name="module_vm_nexus"></a> [vm\_nexus](#module\_vm\_nexus) | ./modules/instance | n/a |
| <a name="module_vm_uc"></a> [vm\_uc](#module\_vm\_uc) | ./modules/instance | n/a |
| <a name="module_vm_windows"></a> [vm\_windows](#module\_vm\_windows) | ./modules/instance | n/a |

## Resources

| Name | Type |
|------|------|
| [yandex_dns_recordset.nexus](https://registry.terraform.io/providers/yandex-cloud/yandex/0.138.0/docs/resources/dns_recordset) | resource |
| [yandex_dns_zone.internal_zone](https://registry.terraform.io/providers/yandex-cloud/yandex/0.138.0/docs/resources/dns_zone) | resource |
| [http_http.my_ip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [yandex_compute_image.ubuntu](https://registry.terraform.io/providers/yandex-cloud/yandex/0.138.0/docs/data-sources/compute_image) | data source |
| [yandex_compute_image.windows](https://registry.terraform.io/providers/yandex-cloud/yandex/0.138.0/docs/data-sources/compute_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_id"></a> [cloud\_id](#input\_cloud\_id) | n/a | `string` | `""` | no |
| <a name="input_core_fraction"></a> [core\_fraction](#input\_core\_fraction) | Гарантированная доля CPU в процентах | `number` | `100` | no |
| <a name="input_cores"></a> [cores](#input\_cores) | Количество vCPU | `number` | `2` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | Размер загрузочного диска в ГБ | `number` | `20` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | Тип загрузочного диска | `string` | `"network-ssd"` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | Список правил для исходящего трафика (egress) в группе безопасности | <pre>list(object({<br/>    protocol       = string<br/>    port           = optional(number)<br/>    v4_cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "protocol": "any",<br/>    "v4_cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | ID каталога в Yandex Cloud | `string` | `""` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | Образ ОС | `string` | `"image_id"` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | Список правил для входящего трафика (ingress) в группе безопасности<br/>  - protocol: протокол (tcp, udp, icmp и т.д.)<br/>  - port: номер порта<br/>  - v4\_cidr\_blocks: список IPv4-подсетей в формате CIDR | <pre>list(object({<br/>    protocol       = string<br/>    port           = optional(number)<br/>    v4_cidr_blocks = list(string)<br/>  }))</pre> | <pre>[<br/>  {<br/>    "protocol": "any",<br/>    "v4_cidr_blocks": [<br/>      "0.0.0.0/0"<br/>    ]<br/>  }<br/>]</pre> | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Имя\_инстанса | `string` | `"vm"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | RAM в ГБ | `number` | `2` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | Metadata to pass to the instance. | `map(string)` | `{}` | no |
| <a name="input_nat"></a> [nat](#input\_nat) | ID подсети | `bool` | `false` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | ID of the VPC network. | `string` | `"network_id"` | no |
| <a name="input_network_name"></a> [network\_name](#input\_network\_name) | Имя сети | `string` | `"network"` | no |
| <a name="input_platform_id"></a> [platform\_id](#input\_platform\_id) | Тип платформы (например, standard-v2) | `string` | `"standard-v3"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | ID групп безопасности | `list(string)` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | имя группы безопасности | `string` | `"sg"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | ID подсети | `string` | `"subnet_id"` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Имя подсети | `string` | `"subnet"` | no |
| <a name="input_token"></a> [token](#input\_token) | n/a | `string` | `""` | no |
| <a name="input_v4_cidr_blocks"></a> [v4\_cidr\_blocks](#input\_v4\_cidr\_blocks) | список IPv4-подсетей в формате CIDR | `list(string)` | `[]` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Use specific availability zone | `string` | `"ru-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_vm_external_ip"></a> [bastion\_vm\_external\_ip](#output\_bastion\_vm\_external\_ip) | n/a |
| <a name="output_dns_nexus_fqdn"></a> [dns\_nexus\_fqdn](#output\_dns\_nexus\_fqdn) | n/a |
| <a name="output_my_current_public_ip"></a> [my\_current\_public\_ip](#output\_my\_current\_public\_ip) | Your current public IP address with /32 mask |
| <a name="output_nexus_admin_password_command"></a> [nexus\_admin\_password\_command](#output\_nexus\_admin\_password\_command) | n/a |
| <a name="output_nexus_url"></a> [nexus\_url](#output\_nexus\_url) | n/a |
| <a name="output_nexus_vm_internal_ip"></a> [nexus\_vm\_internal\_ip](#output\_nexus\_vm\_internal\_ip) | n/a |
| <a name="output_rdp_connection_command"></a> [rdp\_connection\_command](#output\_rdp\_connection\_command) | n/a |
| <a name="output_ssh_connection_command"></a> [ssh\_connection\_command](#output\_ssh\_connection\_command) | n/a |
| <a name="output_uc_vm_internal_ip"></a> [uc\_vm\_internal\_ip](#output\_uc\_vm\_internal\_ip) | n/a |
| <a name="output_windows_internal_ip"></a> [windows\_internal\_ip](#output\_windows\_internal\_ip) | n/a |
<!-- END_TF_DOCS -->