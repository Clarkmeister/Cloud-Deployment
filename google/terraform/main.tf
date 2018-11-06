#####################################################################################################################################################################
# PROVIDERS
#####################################################################################################################################################################

provider "google" {
  credentials = "${file("~/Mjolnir-3056a21c25b5.json")}"
  project     = "mjolnir-214022"
  region      = "us-west1"
}


#####################################################################################################################################################################
# DATA
#####################################################################################################################################################################

data "google_compute_image" "mjolnir_image" {
  name    = "mjolnir-1535045466"
}

#####################################################################################################################################################################
# RESOURCES
#####################################################################################################################################################################

#GLOBAL FORWARDING RULE
resource "google_compute_global_forwarding_rule" "default" {
  name       = "default-rule"
  target     = "${google_compute_target_http_proxy.default.self_link}"
  port_range = "80"
}

#HTTP PROXY
resource "google_compute_target_http_proxy" "default" {
  name        = "test-proxy"
  description = "a description"
  url_map     = "${google_compute_url_map.default.self_link}"
}

#URL MAP
resource "google_compute_url_map" "default" {
  name        = "url-map"
  description = "a description"
  default_service = "${google_compute_backend_service.default.self_link}"
}

#BACKEND SERVICE
resource "google_compute_backend_service" "default" {
  name        = "mj-backend"
  description = "Mjolnir website"
  timeout_sec = 10
  port_name   = "jorts"
  protocol    = "HTTP"
#  region      = "${var.region}"
  backend {
    group = "${google_compute_instance_group.default.self_link}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}

#INSTANCE GROUP (ADD PORTS)
resource "google_compute_instance_group" "default" {
  name        = "${var.project_name}-instance-group"
  description = "Instance group for Mjolnir Web Servers"

  instances = [
    "${google_compute_instance.default.*.self_link}",
  ]
###########SED HERE#############
############END SED#############
  zone = "${var.zone}"
}

#INSTANCES
resource "google_compute_instance" "default" {
  count        = "${var.num_vm}"
  name         = "${var.project_name}-instance-${count.index}"
  machine_type = "n1-standard-1"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "${data.google_compute_image.mjolnir_image.self_link}"
    }
  }
  scratch_disk {}
  network_interface {
    network = "default"
    access_config {
    }
  }

  provisioner "remote-exec" {
    inline =
     [
       "touch envVar.sh",
       "echo \"NUM_CONTAINERS=${var.containers}\" > envVar.sh",
       "sudo mv envVar.sh /usr/bin/",
     ]
    connection
    {
      type = "ssh"
      user = "${var.user}"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}

#HEALTH CHECK PORT 5000
resource "google_compute_health_check" "default" {
  name = "${var.project_name}-health-check"

  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "5000"
  }
}
