## -----------------------------------------------------------------------------
#                                                               vSphere Settings
## -----------------------------------------------------------------------------

data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_host" "hosts" {
  count         = length(var.hosts)
  name          = element(var.hosts,count.index)
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = var.resource_pool
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_backend
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_backend
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template
  datacenter_id = data.vsphere_datacenter.dc.id
}

## -----------------------------------------------------------------------------
#                                                               ignition | users
## -----------------------------------------------------------------------------

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = var.ssh_keys
}

## -----------------------------------------------------------------------------
#                                                             ignition | systemd
## -----------------------------------------------------------------------------

data "ignition_systemd_unit" "docker_runtime" {
  name    = "docker.service"
  enabled = true
  dropin {
    name    = "30-increase-ulimit.conf"
    content = "[Service]\nLimitMEMLOCK=infinity"
  }
}

data "ignition_systemd_unit" "docker_api" {
  name    = "docker-tcp.socket"
  enabled = true
  content = "[Unit]\nDescription=Docker Socket for the API\n\n[Socket]\nListenStream=2375\nBindIPv6Only=both\nService=docker.service\n\n[Install]\nWantedBy=sockets.target"
}

## -----------------------------------------------------------------------------
#                                                               ignition | files
## -----------------------------------------------------------------------------

data "ignition_file" "hostname" {
  count      = length(var.hosts)
  filesystem = "root"
  path       = "/etc/hostname"
  mode       = "420"
  content {
    content = join("",[var.name,count.index])
  }
}

## -----------------------------------------------------------------------------
#                                                            ignition | networkd
## -----------------------------------------------------------------------------

data "template_file" "ignition_networkd_unit_ens192" {
  count     = length(var.hosts)
  template  = file("${path.module}/files/00-ens192.network.tpl")
  vars      = {
    address = cidrhost(var.ipv4_network,var.ipv4_address_start + count.index)
    mask = element(split("/",var.ipv4_network),1)
    gateway = var.ipv4_gateway
    dns = join("\n", formatlist("DNS=%s",var.dns_servers))
  }
}

data "ignition_networkd_unit" "ens192" {
  count   = length(var.hosts)
  name    = "00-ens192.network"
  content = data.template_file.ignition_networkd_unit_ens192.*.rendered[count.index]
}

## -----------------------------------------------------------------------------
#                                                               ignition | input
## -----------------------------------------------------------------------------

data "ignition_config" "input" {
  count    = length(var.hosts)
  users    = [data.ignition_user.core.id]
  files    = [data.ignition_file.hostname.*.id[count.index]]
  networkd = [data.ignition_networkd_unit.ens192.*.id[count.index]]
  systemd  = [
    data.ignition_systemd_unit.docker_runtime.id,
    data.ignition_systemd_unit.docker_api.id
  ]
}
