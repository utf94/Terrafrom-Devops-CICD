resource "google_service_account" "aws_service_account" {
  account_id   = "aws-service-account"
  display_name = "AWS Service Account"
}

data "google_iam_policy" "aws_service_account_policy" {
  binding {
    role    = "roles/iam.serviceAccountTokenCreator"
    members = []
  }
}

resource "google_service_account_iam_policy" "admin-account-iam" {
  service_account_id = google_service_account.aws_service_account.name
  policy_data        = data.google_iam_policy.aws_service_account_policy.policy_data
}