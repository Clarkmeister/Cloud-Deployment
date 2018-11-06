########### INFASTRUCTURE OUTPUT
output "load balancer public ip" {
        value = "${azurerm_public_ip.lbpublicip.ip_address}"
}
output "Virtual Machines public ip's" {
        value = "${azurerm_public_ip.azure.*.ip_address}"
}

