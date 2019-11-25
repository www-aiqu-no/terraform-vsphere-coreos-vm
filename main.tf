# ==============================================================================
#                                         Deploy CoreOS VM from vSphere Template
# ==============================================================================
resource "vsphere_virtual_machine" "vm" {
# ------------------------------------------------------------------------------
  count = "${length(var.hosts)}"
# ------------------------------------------------------------------------------
  annotation = var.vsphere_info
  boot_delay = var.vsphere_boot_delay
# ------------------------------------------------------------------------------
  name     = join("",[var.name,count.index])
  folder   = var.vsphere_folder
  memory   = var.ram_mb
  num_cpus = var.cpu
# ------------------------------------------------------------------------------
  cpu_hot_add_enabled    = true
  cpu_hot_remove_enabled = true
  memory_hot_add_enabled = true
# ------------------------------------------------------------------------------
  disk {
    label            = "disk0"
    unit_number      = 0
    eagerly_scrub    = data.vsphere_virtual_machine.template.disks.0.eagerly_scrub
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    #-- Ensure requested size is > template size
    size = var.disk_gb == "" || var.disk_gb < data.vsphere_virtual_machine.template.disks.0.size ? data.vsphere_virtual_machine.template.disks.0.size : var.disk_gb
  }
# ------------------------------------------------------------------------------
  network_interface {
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types.0
    network_id   = data.vsphere_network.network.id
  }
# ------------------------------------------------------------------------------
  clone {
    linked_clone  = false
    template_uuid = data.vsphere_virtual_machine.template.id
  }
# ------------------------------------------------------------------------------
  vapp {
    properties = {
      "guestinfo.coreos.config.data.encoding" = "base64"
      "guestinfo.coreos.config.data"          = base64encode(data.ignition_config.input.*.rendered[count.index])
    }
  }
# ------------------------------------------------------------------------------
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  host_system_id   = data.vsphere_host.hosts.*.id[count.index]
# ------------------------------------------------------------------------------
  custom_attributes = var.vsphere_custom_attributes
# ------------------------------------------------------------------------------
}
