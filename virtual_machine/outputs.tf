output "id" {
  description = "The unique id of the virtual machine."
  value       = vsphere_virtual_machine.virtual_machine.id
}

output "name" {
  description = "The name of the virtual machine instance when listed on the hypervisor."
  value       = local.instance_name
}

output "virtual_machine" {
  description = "The vSphere virtual machine resource."
  value       = vsphere_virtual_machine.virtual_machine
}

output "ansible_host" {
  description = "The Ansible inventory host resource, or null if enable_ansible_inventory is false."
  value       = one(ansible_host.virtual_machine)
}
