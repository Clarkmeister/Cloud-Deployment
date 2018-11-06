##################################################################################
# OUTPUT
##################################################################################

output "public_domain_address" {
   value = ["${aws_lb.test.dns_name}"]
}

output "vm_public_ip_addresses" {
   value = ["${aws_instance.web.*.public_ip}"]
}

output "total_number_of_servers" {
   value = ["${var.containers * var.num_vm}"]
}

output "number_of_containers" {
   value = ["${var.containers}"]
}

output "number_of_vms" {
   value = ["${var.num_vm}"]
}

