provider "google" {
  project = var.project
  region  = var.region
}

locals {
  function_folder = "../src"
  function_name   = "backend-serverless-function"
}
