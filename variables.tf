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

variable "record_type" {
  description = "The type of the DNS record"
  type        = string
  default     = "A"
}

variable "ttl" {
  description = "The time-to-live for the DNS record (in seconds)"
  type        = number
  default     = 300
}

variable "managed_zone" {
  description = "The name of the managed DNS zone"
  type        = string
  default     = "cloud"
}

variable "dns_name" {
  description = "The DNS name for the A record"
  type        = string
  default     = "mukulsaipendem.me."
}

variable "service_account_id" {
  description = "The ID of the service account for the webapp VM"
  type        = string
  default     = "webapp-vm-service-account"
}

variable "service_account_display_name" {
  description = "The display name of the service account for the webapp VM"
  type        = string
  default     = "WebApp VM Service Account"
}

variable "mailgun_api_key" {
  description = "Mail gun API key"
  type        = string
  default     = "31a3b0d0b82fec7c3c2f3e37b3cd1b25-309b0ef4-68022fc7"
}

variable "domain_name" {
  description = "The domain name for the A record"
  type        = string
  default     = "mukulsaipendem.me"
}

variable "runtime" {
  description = "The runtime for the Cloud Function."
  type        = string
  default     = "python39"
}

variable "entry_point" {
  description = "The entry point to the Cloud Function."
  type        = string
  default     = "hello_pubsub"
}

variable "cloud_zip_name" {
  description = "The name of the ZIP file in the Cloud Storage bucket."
  type        = string
  default     = "serverless-main.zip"
}

variable "cloud_zip_source" {
  description = "Local path to the ZIP file to be uploaded to the Cloud Storage bucket."
  type        = string
  default     = "C:/Users/pende/Downloads/serverless-main/serverless-main.zip"
}

variable "cf_service_account_id" {
  description = "The ID for the Cloud Function service account."
  type        = string
  default     = "cloud-function-sa"
}

variable "cf_service_account_display_name" {
  description = "The display name for the Cloud Function service account."
  type        = string
  default     = "Cloud Function Service Account"
}

variable "vpc_connector_cidr_range" {
  description = "The IP CIDR range for the VPC Connector."
  type        = string
  default     = "10.169.53.0/28"
}

variable "pubsub_topic_name" {
  description = "topic name for pub/sub"
  type        = string
  default     = "verify_email"
}

variable "expiring_time" {
  description = "expring time for email token"
  type        = string
  default     = "2"
}

variable "network_prefix" {
  description = "network prefix"
  type        = string
  default     = "webapp"
}

variable "max_replicas" {
  description = "max_replicas"
  type        = number
  default     = 6
}

variable "min_replicas" {
  description = "min_replicas"
  type        = number
  default     = 3
}

variable "cpu_utilization_target" {
  description = "Target CPU utilization percentage"
  type        = number
  default     = 0.05
}