resource "yandex_dns_zone" "zone1" {
  name        = "zone1"
  zone        = "vvsushkov.ru."
  public      = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "s3"
  type    = "CNAME"
  ttl     = 200
  data    = ["s3.vvsushkov.ru.website.yandexcloud.net."]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "cdn"
  type    = "CNAME"
  ttl     = 200
  data    = ["cl-msb4f27445.edgecdn.ru"]
}