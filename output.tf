output "vpc_id" {
  value = google_compute_network.vpc.id
  description = "The ID of the VPC created."
}

output "webapp_subnet_id" {
  value = google_compute_subnetwork.webapp_subnet.id
  description = "The ID of the webapp subnet created."
}

output "db_subnet_id" {
  value = google_compute_subnetwork.db_subnet.id
  description = "The ID of the db subnet created."
}

output "webapp_route_id" {
  value = google_compute_route.webapp_internet_route.id
  description = "The ID of the internet route for the webapp subnet."
}
