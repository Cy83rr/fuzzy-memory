# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x.
    # If you're using version 1.x, the "features" block is not allowed.
    version = "=2.20.0"
    features {}
    skip_provider_registration = "true"
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
# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "XXX-VNET-RG"
    address_space       = ["10.XXX.0.0/20"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
    environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "SS-MGMT-E1"
    resource_group_name  = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes       = ["10.XXX.1.0/24"]
}

  # Create public IPs
  #resource "azurerm_public_ip" "myterraformpublicip" {
  #    name                         = "myPublicIP"
  #    location                     = "eastus"
  #    resource_group_name          = azurerm_resource_group.myterraformgroup.name
  #    allocation_method            = "Dynamic"
  #
  #    tags = {
  #        environment = "Terraform Demo"
  #    }
  #}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "SS-MGMT-E1-NSG"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

  #    security_rule {
  #        name                       = "SSH"
  #        priority                   = 1001
  #        direction                  = "Inbound"
  #        access                     = "Allow"
  #        protocol                   = "Tcp"
  #        source_port_range          = "*"
  #        destination_port_range     = "22"
  #        source_address_prefix      = "*"
  #        destination_address_prefix = "*"
  #    }

    tags = {
    environment = "Terraform Demo"
    app-name = "Network Infrastructure"
    business-unit = "ETS"
    regulatory = "none"
    }
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "SS-MGMT-E1-NSG"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
  #        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
}

    tags = {
      app-name = "AD Management"
      regulatory = "none"
      business-unit = "ETS"
      environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

#module "network" {
#  source = "./modules/network"

  #name = "${var.name}"

  #cidr = "${var.cidr}"
  #azs = "${var.azs}"
  #public_subnets = "${var.public_subnets}"
#}

# Generate random text for a unique storage account name
resource "random_password" "admin_pass_windows" {
    count = "${length(keys(var.windows_nodes))}"
    length = 16
    special = true
    override_special = "_%@"
}
resource "random_password" "admin_pass_linux" {
    count = "${length(keys(var.linux_nodes))}"
    length = 16
    special = true
    override_special = "_%@"
}

# Create storage account for boot diagnostics
#resource "azurerm_storage_account" "mystorageaccount" {
#    name                        = "diag${random_id.randomId.hex}"
#    resource_group_name         = azurerm_resource_group.myterraformgroup.name
#    location                    = "eastus"
#    account_tier                = "Standard"
#    account_replication_type    = "LRS"
#
#    tags = {
#        environment = "Terraform Demo"
#    }
#}

# Create (and display) an SSH key
#resource "tls_private_key" "example_ssh" {
#  algorithm = "RSA"
#  rsa_bits = 4096
#}
#output "tls_private_key" { value = "${tls_private_key.example_ssh.private_key_pem}" }
locals {
  windows_passes = zipmap(keys(var.windows_nodes), random_password.admin_pass_windows)
  linux_passes = zipmap(keys(var.linux_nodes), random_password.admin_pass_linux)

}

output "merged_windows" {
  value = [ for key,value in var.windows_nodes: merge(value, {"passes" = local.windows_passes[key]}) ]
}
output "merged_linux" {
  value = [for key,value in var.linux_nodes: merge(value, {"passes" = local.linux_passes[key]}) ]
}

locals {
    #windows_passes =

    windows_vms = {
      for key,value in var.windows_nodes:
        key => "${merge(value, {pass= local.windows_passes[key]})}"
        #value["pass"] = windows_passes[key]
        #key => merge(value, { "pass" = lookup(zipmap(keys(var.windows_nodes), random_password.admin_pass_windows), key, "") })

    }
    linux_vms = {
      for key,value in var.linux_nodes: key => flatten(merge(value, {"pass" = local.linux_passes[key] }))
    }
}

resource "azurerm_key_vault" "testvault" {
  name                        = "testvault"
  location                    = azurerm_resource_group.myterraformgroup.location
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
  #soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = "Terraform Demo"
  }
}
resource "azurerm_key_vault_secret" "secrets_for_windows_nodes" {
    for_each = var.windows_nodes
    name = "${each.key}-admin"
    value = each.value.pass
    #TODO add correct id
    key_vault_id = azurerm_key_vault.testvault.id
}
resource "azurerm_key_vault_secret" "secrets_for_linux_nodes" {
    for_each = var.linux_nodes
    name = "${each.key}-admin"
    value = each.value.pass
    #TODO add correct id
    key_vault_id = azurerm_key_vault.testvault.id
}
data "azurerm_key_vault_secret" "windows_secrets" {
  for_each = var.windows_nodes
  name = "${each.key}-admin"
  key_vault_id = azurerm_key_vault.testvault.id
  #TODO include imported secrets from vault into variables
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxVM" {
    for_each = var.linux_nodes
    name                  = each.key
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [azurerm_network_interface.myterraformnic.id]
    size                  = each.value.size

    os_disk {
        name              = "myOsDisk"
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
    admin_username = "admin"
    disable_password_authentication = false
    admin_password = each.value.pass
#    admin_ssh_key {
#        username       = "azureuser"
#        public_key     = tls_private_key.example_ssh.public_key_openssh
#    }

#    boot_diagnostics {
#        storage_account_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
#    }

    tags = {
        environment = "Terraform Demo"
    }
}
# Create windows virtual machine
resource "azurerm_windows_virtual_machine" "windowsVM" {
  for_each = var.windows_nodes
  name                  = each.key
  location              = "eastus"
  resource_group_name   = azurerm_resource_group.myterraformgroup.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = each.value.size
  admin_username      = "admin"
  admin_password      = each.value.pass

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  tags = {
	  environment = "Terraform Demo"
  }
}