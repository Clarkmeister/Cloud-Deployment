#####################################################################################################################################################################
# PROVIDERS
#####################################################################################################################################################################
provider "azurerm" { 
	subscription_id	= "${var.subscription_id}"
	client_id	= "${var.client_id}"
	client_secret	= "${var.client_secret}"
	tenant_id	= "${var.tenant_id}"
}

#####################################################################################################################################################################
# DATA
#####################################################################################################################################################################

#####################################################################################################################################################################
# VARIABLES
#####################################################################################################################################################################

variable "project_name" {
	default = "mjolnirtest"
}

variable "location" {
	default = "West US"
}
variable "subscription_id" 	{}
variable "client_id" 		{}
variable "client_secret" 	{}
variable "tenant_id"		{}
variable "object_id" 		{}
#####################################################################################################################################################################
# RESOURCES
#####################################################################################################################################################################

resource "azurerm_resource_group" "azure" {
  name     = "${var.project_name}resourcegroup"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "azure" {
  name                = "${var.project_name}network"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.azure.location}"
  resource_group_name = "${azurerm_resource_group.azure.name}"
}

resource "azurerm_subnet" "azure" {
    count		 = "3"
    name                 = "${var.project_name}subnet${count.index + 1}"
    resource_group_name  = "${azurerm_resource_group.azure.name}"
    virtual_network_name = "${azurerm_virtual_network.azure.name}"
    address_prefix       = "10.0.${count.index + 1}.0/24"
}

resource "azurerm_storage_account" "azure" {
  name                     	= "${var.project_name}saccount"
  resource_group_name      	= "${azurerm_resource_group.azure.name}"
  location                 	= "${var.location}"
  account_tier             	= "Standard"
  account_replication_type 	= "GRS"
  account_kind			= "StorageV2"
  enable_https_traffic_only	= false  
}

resource "azurerm_key_vault" "keyvault" {
  name                = "mjolnirkeyvault"
  location            = "West US"
  resource_group_name = "${azurerm_resource_group.azure.name}"

  sku {
    name = "standard"
  }

  tenant_id = "${var.tenant_id}"

  access_policy {
    tenant_id = "${var.tenant_id}"
    object_id = "${var.object_id}"

    key_permissions = [
      "get",
      "create",
      "delete",
      "update",
      "import",
    ]

    secret_permissions = [
      "get",
      "set",
      "restore",
      "recover",
      "list",
      "delete",
    ]
  }
}
#resource "azurerm_public_ip" "azure" {
#    name                         = "${var.project_name}publicip"
#    location                     = "${var.location}"
#    resource_group_name          = "${azurerm_resource_group.azure.name}"
#    public_ip_address_allocation = "dynamic"
#}

resource "azurerm_network_security_group" "azure" {
    name                = "${var.project_name}securitygroup"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.azure.name}"

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
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    
    security_rule {
        name                       = "MJOLNIR"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5000-5010"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "WINDOWS"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5985"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

#resource "azurerm_network_interface" "azure" {
#    name                = "${var.project_name}nic${count.index}"
#    location            = "${var.location}"
#    resource_group_name = "${azurerm_resource_group.azure.name}"
#
#    ip_configuration {
#        name                          = "${var.project_name}nicconfiguration"
#        subnet_id                     = "${azurerm_subnet.azure.0.id}"
#        private_ip_address_allocation = "dynamic"
#        public_ip_address_id          = "${azurerm_public_ip.azure.id}"
#    }
#}
