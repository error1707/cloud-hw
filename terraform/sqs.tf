resource "yandex_message_queue" "task-queue" {
  name                        = "task-queue"
  visibility_timeout_seconds  = 60
  receive_wait_time_seconds   = 20

  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
}