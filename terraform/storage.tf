resource "google_storage_bucket" "function_bucket" {
    name     = "${var.project}-function-test"
    location = var.region
}

resource "google_storage_bucket" "input_bucket" {
    name     = "${var.project}-input-test"
    location = var.region
}
