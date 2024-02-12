provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "webapp_subnet" {
  name          = "webapp"
  ip_cidr_range = var.webapp_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "db_subnet" {
  name          = "db"
  ip_cidr_range = var.db_subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_route" "webapp_internet_route" {
  name                    = "webapp-internet-route"
  dest_range              = "0.0.0.0/0"
  network                 = google_compute_network.vpc.id
  next_hop_gateway        = "default-internet-gateway"
  priority                = 1000
}
