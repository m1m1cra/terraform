output "default_instance_public_ip" {
    value = yandex_compute_instance.default.network_interface[0].nat_ip_address
}

output "subnet_id" {
    value = resource.yandex_vpc_subnet.lan-subnet-a.id
}

output "last_ubuntu" {
    value = data.yandex_compute_image.last_ubuntu.id
}
