terraform {
  required_version = ">=1.5.0"

  required_providers {
    # https://registry.terraform.io/providers/vmware/vsphere/latest/docs
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.15.2"
    }

    # https://registry.terraform.io/providers/ansible/ansible/latest/docs
    ansible = {
      version = "~> 1.4.0"
      source  = "ansible/ansible"
    }

    # https://registry.terraform.io/providers/hashicorp/random/latest/docs
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
  }
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs
provider "vsphere" {
  vsphere_server       = var.vsphere.server
  user                 = var.vsphere.user
  password             = var.vsphere.password
  allow_unverified_ssl = true
  api_timeout          = 10
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/datacenter
data "vsphere_datacenter" "datacenter" {
  name = var.vsphere.datacenter
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/datastore
data "vsphere_datastore" "datastore" {
  name          = var.vsphere.datastore
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/datastore_cluster
data "vsphere_compute_cluster" "cluster" {
  name          = var.vsphere.cluster
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/network
data "vsphere_network" "network" {
  name          = var.virtual_machine.network
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/data-sources/virtual_machine
data "vsphere_virtual_machine" "template" {
  name          = var.virtual_machine.template
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

# https://registry.terraform.io/providers/vmware/vsphere/latest/docs/resources/virtual_machine
resource "vsphere_virtual_machine" "virtual_machine" {
  name             = local.instance_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.virtual_machine.folder
  firmware         = data.vsphere_virtual_machine.template.firmware
  annotation       = <<-EOT
    name: ${local.instance_name}
    fqdn: ${local.fqdn}
    description: ${local.description}
    contact: ${var.virtual_machine.contact}
  EOT

  num_cpus  = var.virtual_machine.cpu_count
  memory    = local.ram_size
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = length(data.vsphere_virtual_machine.template.network_interface_types) > 0 ? data.vsphere_virtual_machine.template.network_interface_types[0] : "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = coalesce(var.virtual_machine.disk_size, data.vsphere_virtual_machine.template.disks[0].size)
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks[0].eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }

  # Pass cloud-init config via VMware guestinfo (read by the VMware datasource in cloud-init)
  extra_config = {
    "guestinfo.metadata.encoding" = "base64"
    "guestinfo.metadata" = base64encode(templatefile("${path.module}/templates/metadata.yml.tftpl", {
      hostname = local.hostname
      fqdn     = local.fqdn
    }))

    "guestinfo.userdata.encoding" = "base64"
    "guestinfo.userdata" = base64encode(templatefile("${path.module}/templates/userdata.yml.tftpl", {
      hostname      = local.hostname
      fqdn          = local.fqdn
      create_users  = var.virtual_machine.user != null || try(coalesce(var.virtual_machine.root_password, ""), "") != ""
      user          = var.virtual_machine.user
      root_password = try(coalesce(var.virtual_machine.root_password, ""), "")
    }))

  }
}

# https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/host
resource "ansible_host" "virtual_machine" {
  count  = var.virtual_machine.enable_ansible_inventory ? 1 : 0
  name   = local.fqdn
  groups = length(coalesce(var.virtual_machine.groups, [])) > 0 ? var.virtual_machine.groups : ["terraform_managed"]
  variables = merge(
    {
      instance_name = local.instance_name
      hostname      = local.hostname
      domain        = local.domain
      description   = local.description
    },
    var.virtual_machine.ansible_host_override ? {
      ansible_host = vsphere_virtual_machine.virtual_machine.default_ip_address
    } : {},
    var.virtual_machine.extra_vars
  )
}
