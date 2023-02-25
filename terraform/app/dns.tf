resource "yandex_dns_zone" "zone1" {
  name        = "homework-zone"
  folder_id   = var.yc_folder

  zone    = "vvsushkov.ru."
  public  = true
}

resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "vm"
  type    = "A"
  ttl     = 200
  data    = [local.lbaddress]
}