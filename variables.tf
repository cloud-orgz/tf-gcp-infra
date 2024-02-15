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
