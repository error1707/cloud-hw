resource "yandex_function" "create-task" {
  name               = "create-task"
  user_hash          = "hash_2"
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
    YDB_ENDPOINT = "grpcs://${yandex_ydb_database_serverless.ydb.ydb_api_endpoint}"
    YDB_DATABASE = yandex_ydb_database_serverless.ydb.database_path
  }
  content {
    zip_filename = "create_task.zip"
  }
}
