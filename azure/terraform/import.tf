/*
resource "azurerm_resource_group" "resourcegroupttobeimported" {}

then after running the shell command to import:
 terraform import azurerm_resource_group.resourcegroupttobeimported /subscriptions/ed3c6b29-c710-4f03-8ef2-4025b44e3d40/resourceGroups/resourcegroupttobeimported
change to below:

resource "azurerm_resource_group" "resourcegroupttobeimported" {
  name = "resourcegroupttobeimported"
  location = "eastus"
}
resource "azurerm_virtual_network" "import-vnet" {
  name = "import-vnet"
  location = azurerm_resource_group.resourcegroupttobeimported.location
  resource_group_name = azurerm_resource_group.resourcegroupttobeimported.name
  address_space = ["10.10.65.0/24"]
}*/
