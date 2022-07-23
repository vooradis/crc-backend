# A dedicated Cloud Storage bucket to store the zip source
resource "google_storage_bucket" "source" {
  name = "${var.project}-source"
  location = var.region
}

# Create a fresh archive of the current function folder
data "archive_file" "function" {
  type        = "zip"
  output_path = "temp/function_code_${timestamp()}.zip"
  source_dir  = local.function_folder
}

# The archive in Cloud Stoage uses the md5 of the zip file
# This ensures the Function is redeployed only when the source is changed.
resource "google_storage_bucket_object" "archive" {
  name = "${local.function_folder}_${data.archive_file.function.output_md5}.zip" # will delete old items

  bucket = google_storage_bucket.source.name
  source = data.archive_file.function.output_path

  depends_on = [data.archive_file.function]
}

resource "google_cloudfunctions_function" "function" {
  name        = local.function_name
  description = "My backend function"
  runtime     = "python37"
  region      = var.region
  
  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source.name
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
