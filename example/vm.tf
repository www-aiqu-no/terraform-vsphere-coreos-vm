module "coreos-vm" {
  source  = "www-aiqu-no/coreos-vm/vsphere"
  version = "0.1.0"
# ------------------------------------------------------------------------------
  hosts    = ["my-vsphere-host"]
  ssh_keys = ["list","with","ssh-key(s)"]
# ------------------------------------------------------------------------------
  datacenter        = "some-vsphere-datacenter"
  resource_pool     = "VMC1/Resources"
  datastore_backend = "some-vsphere-datastore"
  network_backend   = "some-vsphere-network"
  vsphere_folder    = "some-vsphere-folder"
# ------------------------------------------------------------------------------
  name     = "my-vm-prefix"
  template = "coreos-template"
# ------------------------------------------------------------------------------
  #cpu     = 2
  #ram_mb  = 2048
  #disk_gb = 20
# ------------------------------------------------------------------------------
  #ipv4_address_start = 100
  #ipv4_network       = "10.0.100.0/24"
  #ipv4_gateway       = "10.0.100.1"
  #dns_servers        = ["10.0.100.10","10.0.100.11"]
  #dns_domain         = "contoso.com"
# ------------------------------------------------------------------------------
  #vsphere_custom_attributes = {
  #  "${data.vsphere_custom_attribute.first.id}"  = "somevalue"
  #  "${data.vsphere_custom_attribute.second.id}" = "somevalue"
  #}
}
