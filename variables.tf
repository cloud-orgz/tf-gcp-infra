variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The region where resources will be created."
  type        = string
}

variable "vpc_name" {
  description = "The vpc_name is the name of the vpc."
  type        = string
}

variable "webapp_subnet_name" {
  description = "The name of the subnet for the webapp."
  type        = string
  default     = "webapp"
}

variable "db_subnet_name" {
  description = "The name of the subnet for the database."
  type        = string
  default     = "db"
}

variable "webapp_subnet_cidr" {
  description = "CIDR block for the webapp subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_cidr" {
  description = "CIDR block for the db subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "zone" {
  description = "The zone where resources will be created."
  type        = string
}

variable "image_family" {
  description = "The image_family of the image."
  type        = string
}

variable "routing_mode" {
  description = "Routing mode"
  type        = string
  default     = "REGIONAL"
}

variable "cloudsql_instance_name" {
  type        = string
  description = "The name of the Cloud SQL instance"
  default     = "cloudsql-instance-mysql"
}

variable "cloudsql_database_version" {
  type        = string
  description = "The version of the SQL database"
  default     = "MYSQL_8_0"
}

variable "cloudsql_region" {
  type        = string
  description = "The region of the Cloud SQL instance"
  default     = "us-central1"
}

variable "cloudsql_tier" {
  type        = string
  description = "The tier of the Cloud SQL instance"
  default     = "db-custom-1-3840"
}

variable "cloudsql_disk_type" {
  type        = string
  description = "The type of disk used by the Cloud SQL instance"
  default     = "PD_SSD"
}

variable "cloudsql_disk_size" {
  type        = number
  description = "The size of disk in GB used by the Cloud SQL instance"
  default     = 100
}

variable "cloudsql_availability_type" {
  type        = string
  description = "The availability type of the Cloud SQL instance"
  default     = "REGIONAL"
}

variable "webapp_database_name" {
  type        = string
  description = "The name of the webapp database"
  default     = "webapp"
}

variable "webapp_user_name" {
  type        = string
  description = "The name of the database user for the webapp"
  default     = "webapp"
}

variable "custom_image_project_id" {
  description = "The project ID where the custom image is stored"
  type        = string
  default     = "cloud-dev-project-414101"
}