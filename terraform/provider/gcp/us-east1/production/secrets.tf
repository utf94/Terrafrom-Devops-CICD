resource "google_secret_manager_secret" "ipsec_vpn_secret" {
  secret_id = "ipsec_vpn_secret"
  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "secret-version-basic" {
  secret = google_secret_manager_secret.ipsec_vpn_secret.id

  secret_data = var.ipsec_vpn_secret

  lifecycle {
    ignore_changes = [secret_data]
  }
}