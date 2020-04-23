output "email" {
    description = "The email address of the custom service account."
    value       = google_service_account.service_account.email
}
