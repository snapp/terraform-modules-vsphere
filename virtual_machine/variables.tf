variable "vsphere" {
  nullable = false
  type = object({
    user       = string
    password   = string
    server     = string
    datacenter = string
    datastore  = string
    cluster    = string
    folder     = optional(string)
  })
  description = <<-EOT
    vsphere = {
      user : "The username used to authenticate to the vSphere server."
      password : "The password used to authenticate to the vSphere server."
      server : "The fully qualified hostname or IP address of the vSphere server."
      datacenter : "The name of the vSphere datacenter in which to create the virtual machine."
      datastore : "The name of the vSphere datastore on which to place the virtual machine."
      cluster : "The name of the vSphere cluster in which to place the virtual machine."
      folder : "The optional vSphere VM folder path used as a default when virtual_machine.folder is not set."
    }
  EOT
}

variable "virtual_machine" {
  nullable = false
  type = object({
    name        = optional(string)
    contact     = string
    description = optional(string)
    template    = string
    folder      = string

    # Compute
    cpu_count = optional(number, 2)
    ram_size  = optional(number, 4)
    disk_size = optional(number)

    # Network
    network  = string
    domain   = optional(string)
    hostname = optional(string)

    # User management
    root_password = optional(string)
    user = optional(object({
      username       = string
      display_name   = string
      password       = optional(string)
      homedir        = optional(string)
      ssh_public_key = string
      sudo_rule      = optional(string)
      uid            = optional(number)
    }))

    # Ansible inventory
    groups                   = optional(list(string), [])
    enable_ansible_inventory = optional(bool, true)
    ansible_host_override    = optional(bool, true)
    extra_vars               = optional(map(string), {})
  })
  description = <<-EOT
    virtual_machine = {
      name : "The optional name of the virtual machine instance when listed on the hypervisor. Defaults to a generated name based on contact."
      contact : "The primary contact for the resources, this should be the username and must be able to receive email by appending your domain to it (e.g. \$\{contact}@example.com) (this person can explain what/why)."
      description: "The optional description of the virtual machine instance."
      template : "The name of the vSphere virtual machine template to clone."
      folder : "The vSphere VM folder path in which to place the virtual machine."
      cpu_count : "The number of virtual CPUs to allocate to the virtual machine (default: 2)."
      ram_size : "The amount of memory allocated to the virtual machine in GB (e.g. 4)."
      disk_size : "The optional OS disk size in gigabytes (e.g. 20). Defaults to the template disk size if not set."
      network : "The name of the vSphere network (port group) to attach to the virtual machine."
      domain : "The optional network domain used for constructing a fqdn for the virtual machine (default: internal)."
      hostname : "The optional short (unqualified) hostname of the instance. Defaults to the instance name."
      root_password : "Password for the root user of the instance (plain-text or hashed)."
      user = {
        username : "User used to access the instance."
        display_name : "Full name of the user used to access the instance."
        password : "The optional password for user used to access the instance (plain-text or hashed)."
        homedir : "The optional home directory for the user (defaults to /home/<username>)."
        ssh_public_key : "SSH public key used to access the instance."
        sudo_rule : "The optional sudo rule applied to the user (e.g. 'ALL=(ALL) NOPASSWD:ALL')."
        uid : "The optional user ID of the user."
      }
      groups : "An array of Ansible inventory group names that the virtual machine should be associated with."
      enable_ansible_inventory : "Whether to create an Ansible inventory host entry for the virtual machine (default: true)."
      ansible_host_override : "When true, injects ansible_host=<VM IPv4> into the inventory host vars so Ansible connects by IP instead of resolving the FQDN (default: true)."
      extra_vars : "An optional map of additional Ansible inventory host variables to merge into the host entry (e.g. { ansible_user = \"myuser\", my_custom_var = \"value\" })."
    }
  EOT
}
