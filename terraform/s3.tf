resource "yandex_storage_bucket" "uploads" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "vvsushkov.uploads"
  acl        = "public-read"
}

resource "yandex_storage_bucket" "results" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "vvsushkov.results"
  acl        = "public-read"
}

resource "yandex_storage_bucket" "models" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket     = "vvsushkov.models"
  acl        = "private"
}