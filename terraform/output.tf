output "sa-access-key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}

#output "sa-secret-key" {
#  value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
#}