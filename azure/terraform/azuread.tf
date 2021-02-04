
/*provider "azuread" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.1.0"

  tenant_id = "00000000-0000-0000-0000-000000000000"
}

resource "azuread_user" "example" {
  user_principal_name = "mtest@ntweekly.local"
  display_name        = "My Test"
  mail_nickname       = "mtest"
  password            = "set password"
}


resource "azuread_group" "example" {
  name = "myGroup"
  display_name = "MyGroup"
  members = [
    azuread_user.example.object_id,
  ]
}

resource "azuread_application" "example" {
  name                       = "example"
  homepage                   = "http://homepage"
  identifier_uris            = ["http://uri"]
  reply_urls                 = ["http://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false

  tags = ["example", "tags", "here"]
}*/


