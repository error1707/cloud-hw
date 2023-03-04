resource "yandex_iam_service_account" "sa" {
  name      = "my-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "lockbox-admin" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "lockbox.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ymq-reader" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "ymq.reader"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage-editor" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage-viewer" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "storage.viewer"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "storage-uploader" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "storage.uploader"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "functions-invoker" {
  folder_id = "b1genngfvit3cknikfuj"
  role      = "serverless.functions.invoker"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

resource "yandex_lockbox_secret" "sa-secret" {
  name = "service account secret"
}

resource "yandex_lockbox_secret_version" "sa-secret-version" {
  secret_id = yandex_lockbox_secret.sa-secret.id

  entries {
    key        = "access-key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  }
  entries {
    key        = "secret-key"
    text_value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  }
}