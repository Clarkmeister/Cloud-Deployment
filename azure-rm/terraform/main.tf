################################################################################
#DESCRIPTION:
#This File creates a load-balanced architecture and opens port 80 on both the load balancer and 
#the VM's. Ports 22 , 80 and 5000-500(num of containers per vm -1) are opened.
#
#ASSUMPTIIONS: 
# this file assumes you generated a secret keypair named id_rsa that is located in your ~/.ssh/ directory
# this file assumes you have access to an azure account with the proper credentials: 
#	-subscription ID 
#	-client ID 
#	-client Secret 
#	-tenant ID
#This link can help you setup/look for all the credetials: https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal
#RESOURCES:
# 	-azure provider in terraform: https://www.terraform.io/docs/providers/azurerm/
#	-azure portal: https://azure.microsoft.com/en-us/features/azure-portal/
################################################################################


#################################################################################
# PROVIDERS
#################################################################################

provider "azurerm" { 
	subscription_id = "${var.subscription_id}"
	client_id	= "${var.client_id}"
	client_secret	= "${var.client_secret}"
	tenant_id	= "${var.tenant_id}"
}

#################################################################################
# VARIABLES
#################################################################################


variable "project_name" {
        default = "mjolnirtest"
}

variable "location" {
        default = "West US"
}

#
#these are custom to each user 
#
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "containers" {
	default = "1"
}

variable "num_vms" {
	default = "1"
}

#################################################################################
# DATA
#################################################################################

data "azurerm_resource_group" "azure" {
  name = "${var.project_name}resourcegroup"
}

data "azurerm_virtual_network" "azure" {
  name                 = "${var.project_name}network"
  resource_group_name  = "${var.project_name}resourcegroup"
}

data "azurerm_subnet" "azure" {
  count 	       = 3
  name                 = "${var.project_name}subnet${count.index + 1}"
  virtual_network_name = "${data.azurerm_virtual_network.azure.name}"
  resource_group_name  = "${data.azurerm_resource_group.azure.name}"
}

data "azurerm_storage_account" "azure" {
  name                 = "${var.project_name}saccount"
  resource_group_name  = "${data.azurerm_resource_group.azure.name}"
}

#data "azurerm_public_ip" "azure" {
#  name = "${var.project_name}publicip"
#  resource_group_name = "${data.azurerm_resource_group.azure.name}"
#}

data "azurerm_network_security_group" "azure" {
  name                = "${var.project_name}securitygroup"
  resource_group_name = "${data.azurerm_resource_group.azure.name}"
}

#data "azurerm_network_interface" "azure" {
#  name                 = "${var.project_name}nic${count.index}"
#  resource_group_name  = "${data.azurerm_resource_group.azure.name}"
#}

data "azurerm_image" "azure" {
  name                = "${var.project_name}centosimage"
  resource_group_name = "${data.azurerm_resource_group.azure.name}"
}

#################################################################################
# RESOURCES
#################################################################################

resource "azurerm_public_ip" "azure" {
    count 			 = "${var.num_vms}"
    name                         = "${var.project_name}publicip${count.index}"
    location                     = "${var.location}"
    resource_group_name          = "${data.azurerm_resource_group.azure.name}"
    public_ip_address_allocation = "dynamic"
}
resource "azurerm_lb_nat_rule" "tcp" { 
    resource_group_name            = "${data.azurerm_resource_group.azure.name}" 
    loadbalancer_id                = "${azurerm_lb.lb.id}" 
    name                           = "Openport80" 
    protocol                       = "tcp" 
    frontend_port                  = "80" 
    backend_port                   = "80" 
    frontend_ip_configuration_name = "LoadBalancerFrontEnd"
} 


resource "azurerm_network_interface" "azure" {
    count 		= "${var.num_vms}"
    name                = "${var.project_name}nic${count.index}"
    location            = "${var.location}"
    resource_group_name = "${data.azurerm_resource_group.azure.name}"

    ip_configuration {
        name                          = "${var.project_name}nicconfiguration"
        subnet_id                     = "${data.azurerm_subnet.azure.0.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${element(azurerm_public_ip.azure.*.id, count.index)}"
	load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.addresspool.id}"]
        load_balancer_inbound_nat_rules_ids     = ["${azurerm_lb_nat_rule.tcp.id}"]
    }
}

############
resource "azurerm_public_ip" "lbpublicip" {
 name                         = "publicIPForLB"
 location                     = "${data.azurerm_resource_group.azure.location}"
 resource_group_name          = "${data.azurerm_resource_group.azure.name}"
 public_ip_address_allocation = "static"
}

resource "azurerm_lb" "lb" {
 name                = "LoadBalancerFrontEnd"
 location            = "${data.azurerm_resource_group.azure.location}"
 resource_group_name = "${data.azurerm_resource_group.azure.name}"

 frontend_ip_configuration {
   name                 = "LoadBalancerFrontEnd"
   public_ip_address_id = "${azurerm_public_ip.lbpublicip.id}"
 }
}

resource "azurerm_lb_backend_address_pool" "addresspool" {
 resource_group_name = "${data.azurerm_resource_group.azure.name}"
 loadbalancer_id     = "${azurerm_lb.lb.id}"
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lb_probe" {
    resource_group_name = "${data.azurerm_resource_group.azure.name}"
    loadbalancer_id     = "${azurerm_lb.lb.id}"
    name                = "tcpProbe"
    protocol            = "tcp"
    port                = 80
    interval_in_seconds = 5
    number_of_probes    = 2
  }



############

resource "azurerm_virtual_machine" "azure" {
    count		  = "${var.num_vms}"
    name                  = "${var.project_name}${count.index}"
    location              = "${var.location}"
    resource_group_name   = "${data.azurerm_resource_group.azure.name}"
    network_interface_ids = ["${element(azurerm_network_interface.azure.*.id, count.index)}"]
    vm_size               = "Standard_A2"
    delete_os_disk_on_termination = "true"
    delete_data_disks_on_termination = "true"


    storage_os_disk {
        name              	= "${var.project_name}OsDisk${count.index}"
        caching           	= "ReadWrite"
        create_option     	= "FromImage"
        managed_disk_type 	= "Standard_LRS"
	os_type			= "Linux"
    }

    storage_image_reference {
	id = "${data.azurerm_image.azure.id}"
#        publisher = "Canonical"
#        offer     = "UbuntuServer"
#        sku       = "16.04.0-LTS"
#        version   = "latest"
    }

    os_profile {
        computer_name  = "${var.project_name}vm${count.index}"
        admin_username = "azureuser"
	admin_password = "@Zurepa55word"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = "${file("~/.ssh/id_rsa.pub")}"
        }
    }
    provisioner "remote-exec" {
    	inline =
     	[
     		# Creates the file that contains enviormental variables that'll be sourced by other scripts
       		"touch envVar.sh",
     		# Initializes the NUM_CONTAINERS variable in the file
       		"echo \"NUM_CONTAINERS=${var.containers}\" >> envVar.sh",
     		# Moves the file to the correct directory to be sourced by other scripts
       		"sudo mv envVar.sh /usr/bin/",
		#adding custom enviortment variable 
		"export NUM_CONTAINERS=${var.containers}",
		# Adding containers to HAPROXY load balancer. 
		"sudo -E /tmp/addIp.sh",
		# starting HAPROXY 
		"sudo /tmp/haproxyHelper.sh start"
     	]
    	connection
    	{
      		type = "ssh"
      		user = "azureuser"
      		private_key = "${file("~/.ssh/id_rsa")}"
    	}
  }
}

#################################################################################
# OUTPUTS
#################################################################################

