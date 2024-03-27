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

# Enable Service Networking API
resource "google_project_service" "service_networking" {
  service = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

# Reserve IP range for Cloud SQL
resource "google_compute_global_address" "private_services_access" {
  name          = "cloudsql-private-services-access"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc_network.id
}

# Create Private Connection for Cloud SQL
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_access.name]
  depends_on              = [google_project_service.service_networking]
}

resource "google_sql_database_instance" "cloudsql_instance_mysql" {
  name             = var.cloudsql_instance_name
  database_version = var.cloudsql_database_version
  region           = var.cloudsql_region
  deletion_protection = false

  settings {
    tier            = var.cloudsql_tier
    availability_type = var.cloudsql_availability_type
    disk_type       = var.cloudsql_disk_type
    disk_size       = var.cloudsql_disk_size

    backup_configuration {
      enabled = true
      binary_log_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.vpc_network.self_link
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_database" "webapp_database_mysql" {
  name     = var.webapp_database_name
  instance = google_sql_database_instance.cloudsql_instance_mysql.name
}

# CloudSQL Database User
resource "random_password" "webapp_user_password" {
  length  = 16
  special = false
}

resource "google_sql_user" "webapp_user_mysql" {
  name     = var.webapp_user_name
  instance = google_sql_database_instance.cloudsql_instance_mysql.name
  password = random_password.webapp_user_password.result
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

resource "google_compute_firewall" "allow_ssh_traffic" {
  name    = "allow-ssh-traffic"
  network = google_compute_network.vpc_network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
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

# Service Account for VM
resource "google_service_account" "webapp_service_account" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

# IAM Roles Binding to Service Account
resource "google_project_iam_member" "logging_admin" {
  project = var.project_id
  role    = "roles/logging.admin"
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

resource "google_project_iam_member" "monitoring_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.webapp_service_account.email}"
}

resource "google_pubsub_topic" "verify_email_topic" {
  name     = var.pubsub_topic_name
  project  = var.project_id
}

resource "google_service_account" "publisher_service_account" {
  account_id   = "publisher-service-account"
  display_name = "Publisher Service Account"
  project      = var.project_id
}

resource "google_project_iam_member" "pubsub_publisher_iam" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.publisher_service_account.email}"
}

resource "google_service_account_key" "publisher_service_account_key" {
  service_account_id = google_service_account.publisher_service_account.name
  private_key_type   = "TYPE_GOOGLE_CREDENTIALS_FILE"
}

resource "google_storage_bucket" "secure_bucket" {
  name     = "secure-bucket-for-creds"
  location                    = var.region
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "creds_file" {
  name   = "creds.json"
  bucket = google_storage_bucket.secure_bucket.name
  content = base64decode(google_service_account_key.publisher_service_account_key.private_key)
}

# Data Source for Latest Custom Image
data "google_compute_image" "latest_custom_image" {
  family  = var.image_family
  project = var.custom_image_project_id
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

  metadata = {
    startup-script = <<-EOT
    #!/bin/bash
    set -e

    # Path to the environment file
    ENV_PATH="/opt/webapp/.env"

    # Check if the .env file already exists
    if [ ! -f "$ENV_PATH" ]; then
      # Ensure the /opt/webapp directory exists
      mkdir -p /opt/webapp

      sudo gsutil cp gs://${google_storage_bucket.secure_bucket.name}/creds.json /opt/webapp/creds.json

      # Write environment variables to /opt/webapp/.env
      echo "DB_USERNAME=${google_sql_user.webapp_user_mysql.name}" >> $ENV_PATH
      echo "DB_PASSWORD=${random_password.webapp_user_password.result}" >> $ENV_PATH
      echo "DB_HOSTNAME=${google_sql_database_instance.cloudsql_instance_mysql.private_ip_address}" >> $ENV_PATH
      echo "DB_NAME=${google_sql_database.webapp_database_mysql.name}" >> $ENV_PATH
      echo "LOGFILE_PATH=/var/logs/webapp" >> $ENV_PATH
      echo "GCP_PROJECTID=${var.project_id}" >> $ENV_PATH
      echo "TOPIC_NAME=${google_pubsub_topic.verify_email_topic.name}" >> $ENV_PATH
      echo "CREDS_JSON=/opt/webapp/creds.json" >> $ENV_PATH
      sudo chown csye6225:csye6225 $ENV_PATH
      sudo chown csye6225:csye6225 /opt/webapp/creds.json
      # Debug: Echo a message to the instance's serial console log
      echo "Startup script has executed."
    else
      echo ".env file already exists, skipping environment setup."
    fi

    EOT
  }
  service_account {
    email  = google_service_account.webapp_service_account.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["webapp-vm", "allow-app-traffic", "deny-all-traffic", "allow-shh-traffic"]

  # Explicitly declare dependencies
  depends_on = [
    google_project_iam_member.logging_admin,
    google_project_iam_member.monitoring_metric_writer,
    google_sql_database_instance.cloudsql_instance_mysql,
    google_storage_bucket_object.creds_file,
    google_project_iam_member.storage_viewer,
    google_service_account.webapp_service_account
  ]
}

resource "google_dns_record_set" "a_record_webapp" {
  name         = var.dns_name
  type         = var.record_type
  ttl          = var.ttl
  managed_zone = var.managed_zone
  project      = var.project_id
  rrdatas      = [google_compute_instance.webapp_vm.network_interface.0.access_config.0.nat_ip]

  depends_on = [
    google_compute_instance.webapp_vm
  ]
}

resource "google_project_service" "vpc_access" {
  service = "vpcaccess.googleapis.com"
}


resource "google_vpc_access_connector" "vpc_connector" {
  name          = "my-vpc-connector"
  project       = var.project_id
  region        = var.cloudsql_region
  network       = google_compute_network.vpc_network.name
  ip_cidr_range = var.vpc_connector_cidr_range

  depends_on = [google_project_service.vpc_access]
}


resource "google_storage_bucket_object" "cloud_zip" {
  name   = var.cloud_zip_name
  bucket = google_storage_bucket.secure_bucket.name
  source = var.cloud_zip_source
}

resource "google_service_account" "cloud_function_service_account" {
  account_id   = var.cf_service_account_id
  display_name = var.cf_service_account_display_name
}

resource "google_project_iam_member" "cloud_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_function_service_account.email}"
}


resource "google_cloudfunctions2_function" "my_cloud_function_gen2" {
  name        = "my-cloud-function"
  description = "Cloud Function with VPC Connector"
  project     = var.project_id

  build_config {
    entry_point = var.entry_point
    runtime     = var.runtime
    source {
      storage_source {
        bucket = google_storage_bucket.secure_bucket.name
        object = google_storage_bucket_object.cloud_zip.name
      }
    }
  }

  service_config {
    vpc_connector = google_vpc_access_connector.vpc_connector.id
    service_account_email = google_service_account.cloud_function_service_account.email
    environment_variables = {
      DB_NAME        = google_sql_database.webapp_database_mysql.name
      DB_USER        = google_sql_user.webapp_user_mysql.name
      DB_PASS        = random_password.webapp_user_password.result
      DB_HOST        = google_sql_database_instance.cloudsql_instance_mysql.private_ip_address
      MAILGUN_API_KEY = var.mailgun_api_key
      DOMIAN_NAME    = var.domain_name
      EXPIRE_MIN     = var.expiring_time
    }
  }

  event_trigger {
    event_type = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic = google_pubsub_topic.verify_email_topic.id
  }

  depends_on = [
    google_vpc_access_connector.vpc_connector,
    google_service_networking_connection.private_vpc_connection
  ]
  location = var.cloudsql_region
}
