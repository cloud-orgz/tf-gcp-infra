variable "project_id" {
  description = "The project ID in GCP where all resources will be deployed."
  default     = "cloud-dev-project-414101"
}

variable "region" {
  description = "The region where GCP resources will be deployed."
  default     = "us-east1"
}

variable "webapp_subnet_cidr" {
  description = "The CIDR block for the webapp subnet."
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "The CIDR block for the db subnet."
  default     = "10.0.2.0/24"
}
