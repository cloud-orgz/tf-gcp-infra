resource "google_compute_network" "vpc_network" {
  name                          = var.vpc_name
  auto_create_subnetworks       = false
  routing_mode                  = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name                     = var.webapp_subnet_name
  ip_cidr_range            = var.webapp_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "db_subnet" {
  name                     = var.db_subnet_name
  ip_cidr_range            = var.db_subnet_cidr
  region                   = var.region
  network                  = google_compute_network.vpc_network.self_link
  private_ip_google_access = true
}

resource "google_compute_route" "webapp_route" {
  name             = "${var.webapp_subnet_name}-internet-route"
  network          = google_compute_network.vpc_network.self_link
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

# Firewall Rule
resource "google_compute_firewall" "allow_app_traffic" {
  name    = "allow-app-traffic"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 900
  direction     = "INGRESS"
}

resource "google_compute_firewall" "deny_ssh_traffic" {
  name    = "deny-all-traffic"
  network = google_compute_network.vpc_network.self_link

  deny {
    protocol = "all"
    ports    = []
  }

  source_ranges = ["0.0.0.0/0"]
  priority      = 1000
  direction     = "INGRESS"
}

#resource "google_compute_firewall" "allow_http_traffic" {
#  name    = "allow-http-traffic"
#  network = google_compute_network.vpc_network.self_link
#
#  allow {
#    protocol = "tcp"
#    ports    = ["80"]
#  }
#
#  target_tags = ["allow-http-traffic"]
#  source_ranges = ["0.0.0.0/0"]
#}



# Data Source for Latest Custom Image
data "google_compute_image" "latest_custom_image" {
  family  = var.image_family
  project = var.project_id
}

# Compute Engine Instance
resource "google_compute_instance" "webapp_vm" {
  name         = "webapp-vm"
  machine_type = "e2-medium"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.latest_custom_image.self_link
      type  = "pd-balanced"
      size  = 100
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.webapp_subnet.self_link

    access_config {
      // This block is intentionally left empty to assign an ephemeral external IP address.
    }
  }

  tags = ["allow-app-traffic", "deny-all-traffic"]
}