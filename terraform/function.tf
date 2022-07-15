resource "google_storage_bucket" "bucket" {
  name     = "backend-infra-bucket"
  location = "australia-southeast1"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.bucket.name
  source = "../src"
}

resource "google_cloudfunctions_function" "function" {
  name        = "backend-cloud-function"
  description = "My function"
  runtime     = "python37"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  entry_point           = "visitor_count"
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}
