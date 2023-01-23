resource "yandex_mdb_clickhouse_cluster" "clickhouse" {
  name        = "clickhouse"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.network.id

  clickhouse {
    resources {
      resource_preset_id = "b1.medium"
      disk_type_id       = "network-hdd"
      disk_size          = 32
    }
  }

  database {
    name = "db"
  }

  user {
    name     = "vvsushkov"
    password = "password"
    permission {
      database_name = "db"
    }
    settings {
      allow_ddl = true
    }
  }

  host {
    type      = "CLICKHOUSE"
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private-subnet.id
  }

  service_account_id = "aje9gkd35mata7oocicv"

  cloud_storage {
    enabled = false
  }

  maintenance_window {
    type = "ANYTIME"
  }
}