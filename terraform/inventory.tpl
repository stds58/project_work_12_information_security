
[bastion]
vm_bastion ansible_host=${vm_bastion_ip} ansible_user=ubuntu

[uc]
vm_uc ansible_host=${vm_uc_ip} ansible_user=ubuntu

[nexus]
vm_nexus ansible_host=${vm_nexus_ip} ansible_user=ubuntu

[test-rdp]
vm_linux_rdp ansible_host=${vm_linux_rdp_ip} ansible_user=ubuntu

# Подключение через бастион
[all:vars]
ansible_ssh_private_key_file=~/.ssh/terraform_20250320
ansible_ssh_common_args=-o ProxyCommand="ssh -W %h:%p -i ~/.ssh/terraform_20250320 ubuntu@${vm_bastion_ip}"
domain_name = nexus.example