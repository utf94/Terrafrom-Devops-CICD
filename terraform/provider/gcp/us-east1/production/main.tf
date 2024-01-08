provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = file("inf-production-auth.json")
}

resource "google_storage_bucket" "gcp_terraform_state_bucket" {
  name          = "${var.namespace}-${var.stage}-terraform-state"
  project       = var.gcp_project
  location      = var.gcp_region
  storage_class = "REGIONAL"
  force_destroy = false
  versioning {
    enabled = true
  }
}

terraform {
  backend "gcs" {
    bucket      = "inf-production-terraform-state"
    prefix      = "terraform/state"
    credentials = "inf-production-auth.json"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.80.0"
    }
  }
}

provider "google-beta" {
  credentials = file("inf-production-auth.json")
  project     = var.gcp_project
  region      = var.gcp_region
}
