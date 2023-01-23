data "yandex_compute_image" "container-optimized-image" {
  family = "container-optimized-image"
}

resource "yandex_compute_instance" "nginx" {
  name = "nginx"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.container-optimized-image.id
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

resource "yandex_compute_instance_group" "logbroker" {
  name = "logbroker"

  instance_template {
    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      initialize_params {
        image_id = data.yandex_compute_image.container-optimized-image.id
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.private-subnet.id]
    }

    metadata = {
      user-data = file("./cloud_config.yaml")
    }
  }
  service_account_id = "aje9gkd35mata7oocicv"
  allocation_policy {
    zones = ["ru-central1-a"]
  }
  deploy_policy {
    max_unavailable = 1
    max_expansion = 0
  }
  scale_policy {
    fixed_scale {
      size = 2
    }
  }
}