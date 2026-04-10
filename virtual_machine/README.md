# Terraform vSphere virtual_machine Module

This terraform module provides a convenience for instantiating a virtual machine in a vSphere environment by cloning from an existing template.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.5.0 |
| <a name="requirement_ansible"></a> [ansible](#requirement\_ansible) | ~> 1.4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.8.1 |
| <a name="requirement_vsphere"></a> [vsphere](#requirement\_vsphere) | ~> 2.15.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansible"></a> [ansible](#provider\_ansible) | 1.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |
| <a name="provider_vsphere"></a> [vsphere](#provider\_vsphere) | 2.15.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ansible_host.virtual_machine](https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/host) | resource |
| [random_id.virtual_machine](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [vsphere_virtual_machine.virtual_machine](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/resources/virtual_machine) | resource |
| [vsphere_compute_cluster.cluster](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/compute_cluster) | data source |
| [vsphere_datacenter.datacenter](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/datacenter) | data source |
| [vsphere_datastore.datastore](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/datastore) | data source |
| [vsphere_network.network](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/network) | data source |
| [vsphere_virtual_machine.template](https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/virtual_machine) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_virtual_machine"></a> [virtual\_machine](#input\_virtual\_machine) | virtual\_machine = {<br/>  name : "The optional name of the virtual machine instance when listed on the hypervisor. Defaults to a generated name based on contact."<br/>  contact : "The primary contact for the resources, this should be the username and must be able to receive email by appending your domain to it (e.g. \$\{contact}@example.com) (this person can explain what/why)."<br/>  description: "The optional description of the virtual machine instance."<br/>  template : "The name of the vSphere virtual machine template to clone."<br/>  folder : "The vSphere VM folder path in which to place the virtual machine."<br/>  cpu\_count : "The number of virtual CPUs to allocate to the virtual machine (default: 2)."<br/>  ram\_size : "The amount of memory allocated to the virtual machine in GB (e.g. 4)."<br/>  disk\_size : "The optional OS disk size in gigabytes (e.g. 20). Defaults to the template disk size if not set."<br/>  network : "The name of the vSphere network (port group) to attach to the virtual machine."<br/>  domain : "The optional network domain used for constructing a fqdn for the virtual machine (default: internal)."<br/>  hostname : "The optional short (unqualified) hostname of the instance. Defaults to the instance name."<br/>  root\_password : "Password for the root user of the instance (plain-text or hashed)."<br/>  user = {<br/>    username : "User used to access the instance."<br/>    display\_name : "Full name of the user used to access the instance."<br/>    password : "The optional password for user used to access the instance (plain-text or hashed)."<br/>    homedir : "The optional home directory for the user (defaults to /home/<username>)."<br/>    ssh\_public\_key : "SSH public key used to access the instance."<br/>    sudo\_rule : "The optional sudo rule applied to the user (e.g. 'ALL=(ALL) NOPASSWD:ALL')."<br/>    uid : "The optional user ID of the user."<br/>  }<br/>  groups : "An array of Ansible inventory group names that the virtual machine should be associated with."<br/>  enable\_ansible\_inventory : "Whether to create an Ansible inventory host entry for the virtual machine (default: true)."<br/>  ansible\_host\_override : "When true, injects ansible\_host=<VM IPv4> into the inventory host vars so Ansible connects by IP instead of resolving the FQDN (default: false)."<br/>  extra\_vars : "An optional map of additional Ansible inventory host variables to merge into the host entry (e.g. { ansible\_user = \"myuser\", my\_custom\_var = \"value\" })."<br/>} | <pre>object({<br/>    name        = optional(string)<br/>    contact     = string<br/>    description = optional(string)<br/>    template    = string<br/>    folder      = string<br/><br/>    # Compute<br/>    cpu_count = optional(number, 2)<br/>    ram_size  = optional(number, 4)<br/>    disk_size = optional(number)<br/><br/>    # Network<br/>    network  = string<br/>    domain   = optional(string)<br/>    hostname = optional(string)<br/><br/>    # User management<br/>    root_password = optional(string)<br/>    user = optional(object({<br/>      username       = string<br/>      display_name   = string<br/>      password       = optional(string)<br/>      homedir        = optional(string)<br/>      ssh_public_key = string<br/>      sudo_rule      = optional(string)<br/>      uid            = optional(number)<br/>    }))<br/><br/>    # Ansible inventory<br/>    groups                   = optional(list(string), [])<br/>    enable_ansible_inventory = optional(bool, true)<br/>    ansible_host_override    = optional(bool, false)<br/>    extra_vars               = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_vsphere"></a> [vsphere](#input\_vsphere) | vsphere = {<br/>  user : "The username used to authenticate to the vSphere server."<br/>  password : "The password used to authenticate to the vSphere server."<br/>  server : "The fully qualified hostname or IP address of the vSphere server."<br/>  datacenter : "The name of the vSphere datacenter in which to create the virtual machine."<br/>  datastore : "The name of the vSphere datastore on which to place the virtual machine."<br/>  cluster : "The name of the vSphere cluster in which to place the virtual machine."<br/>  folder : "The optional vSphere VM folder path used as a default when virtual\_machine.folder is not set."<br/>} | <pre>object({<br/>    user       = string<br/>    password   = string<br/>    server     = string<br/>    datacenter = string<br/>    datastore  = string<br/>    cluster    = string<br/>    folder     = optional(string)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ansible_host"></a> [ansible\_host](#output\_ansible\_host) | The Ansible inventory host resource, or null if enable\_ansible\_inventory is false. |
| <a name="output_id"></a> [id](#output\_id) | The unique id of the virtual machine. |
| <a name="output_name"></a> [name](#output\_name) | The name of the virtual machine instance when listed on the hypervisor. |
| <a name="output_virtual_machine"></a> [virtual\_machine](#output\_virtual\_machine) | The vSphere virtual machine resource. |
<!-- END_TF_DOCS -->

## Examples
- [multiple_virtual_machines](examples/example-multiple_virtual_machines/README.md)

## Licensing

GNU General Public License v3.0 or later

See [LICENSE](https://www.gnu.org/licenses/gpl-3.0.txt) to see the full text.
