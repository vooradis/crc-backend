provider "google" {
  project = var.project
  region  = var.region
}

locals {
  function_folder = "../src"
  function_name   = "backend-serverless-function"
  api_config_id_prefix     = "api"
  display_name             = "API Gateway"
}
