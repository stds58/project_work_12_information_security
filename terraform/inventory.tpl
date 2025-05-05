
[bastion]
vm_bastion ansible_host=${vm_bastion_ip} ansible_user=ubuntu

[uc]
vm_uc ansible_host=${vm_uc_ip} ansible_user=ubuntu

[nexus]
vm_nexus ansible_host=${vm_nexus_ip}  ansible_user=ubuntu

[windows]
vm_windows ansible_host=${vm_windows_ip} ansible_user=ubuntu


[all:vars]
ansible_ssh_private_key_file=~/.ssh/terraform_20250320
