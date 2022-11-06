terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }


backend "s3" {
    endpoint   = "storage.yandexcloud.net"
    bucket     = "mybucketdev1"
    region     = "ru-central1"
    key        = "main/terraform.tfstate"
    access_key = "YCAJEVXf7VlXCN_A5SCS7i7rY"
    secret_key = "YCOY2lgQ9tbWd2V1bYuWZN_FqITv3IEvTQ8GSqnu"
    skip_region_validation      = true
    skip_credentials_validation = true
}
}

provider "yandex" {
  service_account_key_file = "/home/avdeevan/keys/key.json"
  cloud_id  = "b1goii5kdl1folbkbvs5"
  folder_id = "b1gnbvfpg8dclod4m0st"
  zone      = "ru-central1-a"
}



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

locals {
 count_vm = {
  stage = 1
  prod = 2
 }
}

locals {
 type_vm = {
  stage = "standard-v1"
  prod  = "standard-v2"
 }
}

locals {
 instances = {
  "standart-v1" = data.yandex_compute_image.last_ubuntu.id
  "standart-v2" = data.yandex_compute_image.last_ubuntu.id
 }
}


resource "yandex_compute_instance" "web" {
  name = "test-instance"
  platform_id = local.type_vm[terraform.workspace]
  count = local.count_vm[terraform.workspace]
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
  lifecycle {
   create_before_destroy = true
 }
}


resource "yandex_compute_instance" "default" {
 for_each = local.instances 
  name = "test-instance"
  platform_id = local.type_vm[terraform.workspace]
  resources {
    core_fraction = 5 
    cores  = 2 
    memory = 1 
  }

  boot_disk {
    initialize_params {
      image_id = each.value
    }
  }

  network_interface {
    subnet_id = resource.yandex_vpc_subnet.lan-subnet-a.id
    nat = true 
  }
}

