resource "local_file" "ansible_hosts" {
  content = "[balancer]\n${
        yandex_compute_instance.nginx.network_interface.0.nat_ip_address
    }\n\n[logbroker]\n${
        join("\n", [for x in yandex_compute_instance_group.logbroker.instances : x.network_interface.0.ip_address])
    }\n\n[logbroker:vars]\nansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p -q vvsushkov@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}\"'\n\n[clickhouse]\n${
        yandex_mdb_clickhouse_cluster.clickhouse.host.0.fqdn
    }\n\n[clickhouse:vars]\nansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p -q vvsushkov@${yandex_compute_instance.nginx.network_interface.0.nat_ip_address}\"'"
  filename = "hosts"
}

output "external_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface.0.nat_ip_address
}

output "internal_ip_address_nginx" {
  value = yandex_compute_instance.nginx.network_interface.0.ip_address
}

output "clickhouse_fqdn" {
  value = yandex_mdb_clickhouse_cluster.clickhouse.host.0.fqdn
}