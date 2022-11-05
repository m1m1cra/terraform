terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  service_account_key_file = "/home/avdeevan/keys/key.json"
  cloud_id  = "b1goii5kdl1folbkbvs5"
  folder_id = "b1gnbvfpg8dclod4m0st"
  zone      = "ru-central1-a"
}


data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts"  
}

data "yandex_vpc_subnet" "default_a" {
  name = "default-ru-central1-a" 
}


resource "yandex_compute_instance" "default" { 
  name = "test-instance"
	platform_id = "standard-v1" 
  resources {
    core_fraction = 5 
    cores  = 2 
    memory = 1 
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.last_ubuntu.id
    }
  }

  network_interface {
    subnet_id = data.yandex_vpc_subnet.default_a.subnet_id
    nat = true 
  }
}
