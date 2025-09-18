resource "google_compute_instance" "vm_for_each" {
  for_each     = var.instances
  name         = "vm-${each.key}"
  machine_type = each.value.machine_type
  zone         = each.value.zone

  boot_disk {
    initialize_params {
      image = each.value.image
      size  = each.value.size
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

}
