# tf-gcp-infra

Certainly! Below is a template for a `README.md` file that you can adapt for your Terraform project. This README includes an introduction to the enabled API services, an explanation of the code, and instructions on how to run it.

## GCP Networking Infrastructure with Terraform

This project contains Terraform code to set up a networking infrastructure in the Google Cloud Platform (GCP). It creates a Virtual Private Cloud (VPC) with specific subnets for a web application and a database, without any default routes.

## Prerequisites

Before using this Terraform code, ensure that the following APIs are enabled in your GCP project:

- `compute.googleapis.com`: Enables resources within Compute Engine and is required to create VPCs, subnets, and related resources.
- `cloudresourcemanager.googleapis.com`: Allows Terraform to manage project-level resources and permissions.
- `servicenetworking.googleapis.com`: Facilitates service networking features like VPC peering, needed for secure connections between Google services and your VPC.

To enable these APIs, run the following commands:

```sh
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

## Code Structure

- `main.tf`: Contains the core resource definitions for the VPC, subnets, and routes.
- `variables.tf`: Defines the variables used across the configuration.
- `providers.tf`: Configures the GCP provider and specifies the version.
- `version.tf`: Sets the required Terraform version and provider dependencies.
- `dev.tfvars`: Contains variable definitions specific to the development environment.

## How to Run the Code

1. **Initialize Terraform:**

```sh
terraform init
```

This command initializes the Terraform environment, downloads the GCP provider, and prepares the environment for use.

2. **Plan the Infrastructure:**

```sh
terraform plan -var-file="dev.tfvars"
```

This command creates an execution plan, which allows you to review the changes that Terraform will perform to reach the desired state defined in the configuration.

3. **Apply the Infrastructure:**

```sh
terraform apply -var-file="dev.tfvars"
```

This command applies the changes required to reach the desired state of the configuration. It will create the VPC, subnets, and the specified route.

4. **Destroy the Infrastructure (if needed):**

```sh
terraform destroy -var-file="dev.tfvars"
```

This command destroys the Terraform-managed infrastructure, which is useful when you need to clean up resources.

## Note

Ensure you have authenticated to GCP with the appropriate credentials before running Terraform commands. Use the `gcloud auth application-default login` command to authenticate.

Replace the placeholder values in `dev.tfvars` with your actual configuration before running the plan or apply commands.

Always review the plan before applying to avoid unintended changes to your infrastructure.
