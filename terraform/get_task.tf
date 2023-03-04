resource "yandex_function" "get-task" {
  name               = "get-task"
  user_hash          = "hash_1"
  runtime            = "python39"
  entrypoint         = "index.main"
  memory             = "1024"
  execution_timeout  = "20"
  service_account_id = yandex_iam_service_account.sa.id
  environment = {
    YDB_ENDPOINT = "grpcs://${yandex_ydb_database_serverless.ydb.ydb_api_endpoint}"
    YDB_DATABASE = yandex_ydb_database_serverless.ydb.database_path
  }
  content {
    zip_filename = "get_task.zip"
  }
}
