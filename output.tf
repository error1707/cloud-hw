resource "local_file" "ansible_hosts" {
  content = "[vm]\n${
        yandex_compute_instance_group.vm.instances.0.network_interface.0.nat_ip_address
    }\n\n[tank]\n${
        yandex_compute_instance_group.vm.instances.1.network_interface.0.nat_ip_address
    }\n\n[metrics]\n${
        yandex_compute_instance_group.vm.instances.2.network_interface.0.nat_ip_address
    }\n"
  filename = "hosts"
}