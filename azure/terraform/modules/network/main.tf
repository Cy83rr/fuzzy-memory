resource "azurerm_resource_group" "myterraformgroup" {
    name     = "myResourceGroup"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
	    regulatory = "none"
	    business-unit = "ETS"
	    app-name = "AD Management"
	    project-code = ""
	    originating-request-number = ""
    }
}
# Create virtual network
  resource "azurerm_virtual_network" "myterraformnetwork" {
    name                = "XX-VNET-RG"
    address_space       = ["10.XXX.0.0/20"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    tags = {
    app-name = "Network Infrastructure"
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
