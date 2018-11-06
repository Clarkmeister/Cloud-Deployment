########### INFASTRUCTURE OUTPUT 
output "resource group name" {
	value = "${azurerm_resource_group.azure.name}"
}

output "resource group id" {
	value = "${azurerm_resource_group.azure.id}"
}


output "security group name" {
	value = "${azurerm_network_security_group.azure.name}"
}


