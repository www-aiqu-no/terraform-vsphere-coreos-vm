# terraform-vsphere-coreos-vm
Deploy CoreOS virtual machine to vSphere cluster

## Using the modules (from github)
1) Use the following module-block in your terraform-code:
```hcl
module "my_module_name" {
  source "github.com:www-aiqu-no/terraform-vsphere-coreos-vm.git?ref=v0.0.1"
  ...
}
```
2) Optionally add 'ref' tag corresponding with a valid release-tag
3) Run 'terraform get' to download module

See 'example' folder & variables for configuration-options

## Custom Attributes (v0.0.2)
If you already have custom attributes defined, these can be included by
importing the id via "data-source", and adding attributes under the
"custom_attributes" map (ref. example)
