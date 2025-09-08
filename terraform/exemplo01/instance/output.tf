output "vm-name" {
    value = google_compute_instance.exemplo_vm.name
  
}

output "ip-pub" {
    value = google_compute_instance.exemplo_vm.network_interface[0].access_config[0].nat_ip
  
}