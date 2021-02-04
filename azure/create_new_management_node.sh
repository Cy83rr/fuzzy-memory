# the idea - generate random password for admin, generate almost identical windows/linux nodes, defining only names in vars
az login
az account set --subscription=""
az ad sp create-for-rbac --role="Contributor" -–scopes="/subscriptions/<subscription_id>"
az login --service-principal -u <service_principal_name> -p "<service_principal_password>" --tenant "<service_principal_tenant>"


# generate pass for admin
#az keyvault secret set --vault-name "keyvault_for_mng_nodes" --name "admin" --value $PASS
terraform/terraform plan
terraform/terraform apply -var variable_name="value"
