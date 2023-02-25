resource "yandex_cdn_origin_group" "my_group" {
  name = "CDN origin group"
  use_next = true

  origin {
    source = "www.vvsushkov.ru.storage.yandexcloud.net"
  }
}

resource "yandex_cdn_resource" "my_resource" {
  cname               = "cdn.vvsushkov.ru"
  origin_protocol     = "https"
  origin_group_id     = yandex_cdn_origin_group.my_group.id
  options {
    custom_host_header = "www.vvsushkov.ru.storage.yandexcloud.net"
  }
  ssl_certificate {
    type = "lets_encrypt_gcore"
  }
}