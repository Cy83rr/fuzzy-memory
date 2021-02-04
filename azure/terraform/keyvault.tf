
resource "azurerm_key_vault" "testvault" {
  name                        = "terraform-demo-testvault"
  location                    = azurerm_resource_group.myterraformgroup.location
  resource_group_name         = azurerm_resource_group.myterraformgroup.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = true
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
      "backup",
      "delete",
      "list",
      "purge",
      "recover",
      "restore",
      "set"
    ]

    storage_permissions = [
      "get",
    ]
  }

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["185.34.41.62"]
    virtual_network_subnet_ids = [azurerm_subnet.myterraformsubnet.id]
  }

  tags = {
    environment = "Terraform Demo"
  }
}

resource "azurerm_key_vault_secret" "secrets_for_linux_nodes" {
    for_each = var.linux_nodes
    name = "${each.key}-admin"
    value = each.value.pass
    key_vault_id = azurerm_key_vault.testvault.id
}