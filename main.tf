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

#data "yandex_vpc_subnet" "lan-subnet-a" {
#  name = "lan-subnet-a"
#}


resource "yandex_vpc_network" "lab-net" {
  name = "lab-network"
}

resource "yandex_vpc_subnet" "lan-subnet-a" {
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.lab-net.id}"
}

data "yandex_compute_image" "last_ubuntu" {
  family = "ubuntu-2204-lts"  
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
    subnet_id = resource.yandex_vpc_subnet.lan-subnet-a.id
    nat = true 
  }
}
