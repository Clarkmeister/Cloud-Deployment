#output "image_self_link" {
#  value = "${data.google_compute_image.mjolnir_image.self_link}"
#}

output "fwd_rule_ip_address" {
  value = "${google_compute_global_forwarding_rule.default.ip_address}"
}

output "instance ip address" {
  value = "${google_compute_instance.default.*.network_interface.0.access_config.0.assigned_nat_ip}"
}
