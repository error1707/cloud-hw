resource "yandex_function" "validate-input" {
  name               = "validate-input"
  user_hash          = "hash_7"
  runtime            = "python39"
  entrypoint         = "index.main"
  memory             = "1024"
  execution_timeout  = "20"
  service_account_id = yandex_iam_service_account.sa.id
  secrets {
    id = yandex_lockbox_secret.sa-secret.id
    version_id = yandex_lockbox_secret_version.sa-secret-version.id
    key = "access-key"
    environment_variable = "AWS_ACCESS_KEY"
  }
  secrets {
    id = yandex_lockbox_secret.sa-secret.id
    version_id = yandex_lockbox_secret_version.sa-secret-version.id
    key = "secret-key"
    environment_variable = "AWS_SECRET_KEY"
  }
  environment = {
    QUEUE_URL = yandex_message_queue.task-queue.id
    YDB_ENDPOINT = "grpcs://${yandex_ydb_database_serverless.ydb.ydb_api_endpoint}"
    YDB_DATABASE = yandex_ydb_database_serverless.ydb.database_path
  }
  content {
    zip_filename = "validate_input.zip"
  }
}

resource "yandex_function_trigger" "bucket-trigger" {
  name        = "bucket-trigger"
  object_storage {
     bucket_id = yandex_storage_bucket.uploads.id
     create    = true
  }
  function {
    id = yandex_function.validate-input.id
    service_account_id = yandex_iam_service_account.sa.id
  }
}