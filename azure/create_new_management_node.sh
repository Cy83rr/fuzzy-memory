# the idea - generate random password for admin, generate almost identical windows/linux nodes, defining only names in vars
az login
az account set --subscription="bf476486-f84d-4dea-8e46-6e39dc7a1ad6" # elanco lab subscription
# generate pass for elancoadmin
#az keyvault secret set --vault-name "keyvault_for_mng_nodes" --name "elancoadmin" --value $PASS
terraform/terraform plan
terraform/terraform apply -var variable_name="value"
