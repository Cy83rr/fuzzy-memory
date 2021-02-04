/*terraform {
  backend "azurerm" {
    resource_group_name   = "tstate"
    storage_account_name  = "tstate09762"
    container_name        = "tstate"
    key                   = "terraform.tfstate"
  }
}*/

# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    features {}
}
data "azurerm_client_config" "current" {}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}


resource "random_password" "admin_pass_linux" {
    count = length(keys(var.linux_nodes))
    length = 16
    special = true
    override_special = "_%@"
}


locals {
  linux_passes = zipmap(keys(var.linux_nodes), random_password.admin_pass_linux)

}

output "merged_linux" {
  value = [for key,value in var.linux_nodes: merge(value, {"pass" = local.linux_passes[key].result}) ]
}

locals {
    #windows_passes =

/*    windows_vms = {
      for key,value in var.windows_nodes:
        key => "${merge(value, {pass= local.windows_passes[key]})}"
        #value["pass"] = windows_passes[key]
        #key => merge(value, { "pass" = lookup(zipmap(keys(var.windows_nodes), random_password.admin_pass_windows), key, "") })

    }*/
    linux_vms = {
      for key,value in var.linux_nodes:
        key => merge(value, {"pass" = local.linux_passes[key].result })
    }
}


resource "azurerm_key_vault_secret" "secrets_for_linux_nodes" {
    for_each = var.linux_nodes
    name = "${each.key}-admin"
    value = each.value.pass
    key_vault_id = azurerm_key_vault.testvault.id
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxVM" {
    for_each = local.linux_vms
    name                  = each.key
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = each.value.size

    os_disk {
        name              = each.key
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    computer_name  = "each.key"
    admin_username = "Terraformadmin"
    disable_password_authentication = false
    admin_password = each.value.pass
    tags = {
        environment = "Terraform Demo"
    }
}
