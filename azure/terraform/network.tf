# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "XXX-VNET-RG"
    address_space       = ["10.192.0.0/20"]
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
    address_prefixes       = ["10.192.1.0/24"]
    service_endpoints = ["Microsoft.KeyVault"]
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "SS-MGMT-E1-NSG"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

      security_rule {
          name                       = "SSH"
          priority                   = 1001
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
      }

        security_rule {
          name                       = "myIP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "185.34.41.62"
          destination_address_prefix = "*"
      }

    tags = {
    environment = "Terraform Demo"

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
}

    tags = {
      environment = "Terraform Demo"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.myterraformsubnet.id
  network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}