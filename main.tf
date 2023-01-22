terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

resource "yandex_compute_instance" "vm" {
  name = "vm"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8j8o5bguvqglmqls7q"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.private-subnet.id
  }

  metadata = {
    user-data = file("./cloud_config.yaml")
  }
}

resource "yandex_compute_instance" "nat" {
  name = "nat"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8o8aph4t4pdisf1fio"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public-subnet.id
    nat       = true
  }

  metadata = {
    user-data = file("./cloud_config.yaml")
  }
}

resource "yandex_vpc_network" "network" {
  name = "network"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name           = "public-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.0.0.0/16"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  name           = "private-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  route_table_id = yandex_vpc_route_table.nat-rt.id
  v4_cidr_blocks = ["192.168.0.0/16"]
}

resource "yandex_vpc_route_table" "nat-rt" {
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface.0.ip_address
  }
}

output "external_ip_address_nat" {
  value = yandex_compute_instance.nat.network_interface.0.nat_ip_address
}

output "internal_ip_address_nat" {
  value = yandex_compute_instance.nat.network_interface.0.ip_address
}

output "internal_ip_address_vm" {
  value = yandex_compute_instance.vm.network_interface.0.ip_address
}