# A dedicated Cloud Storage bucket to store the zip source
resource "google_storage_bucket" "source" {
  name     = "${var.project}-source"
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

resource "google_api_gateway_api" "api_gw" {
  provider     = google-beta
  api_id       = "${var.project}-api-id"
  project      = var.project
  display_name = local.display_name
}

resource "google_api_gateway_api_config" "api_cfg" {
  provider             = google-beta
  api                  = google_api_gateway_api.api_gw.api_id
  api_config_id_prefix = local.api_config_id_prefix
  project              = var.project
  display_name         = local.display_name

  openapi_documents {
    document {
      path     = "openapi.yaml"
      contents = filebase64("openapi.yaml")
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "api_gw" {
  provider = google-beta
  region   = var.region
  project  = var.project
  
  api_config   = google_api_gateway_api_config.api_cfg.id

  gateway_id   = "${var.project}-gateway-id"
  display_name = local.display_name
  
  depends_on   = [google_api_gateway_api_config.api_cfg]
}

# IAM entry for all users to invoke the function
resource "google_api_gateway_gateway_iam_member" "member" {
  provider = google-beta
  project  = google_api_gateway_gateway.api_gw.project
  region   = google_api_gateway_gateway.api_gw.region
  gateway  = google_api_gateway_gateway.api_gw.gateway_id
  role     = "roles/apigateway.viewer"
  member   = "allUsers"
}
