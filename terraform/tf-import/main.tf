resource "google_compute_instance" "default" {
  name = "vm-importada"
  machine_type = "e2-small"
  zone = "us-central1-a"
  
  boot_disk {
    initialize_params {
      image = "debian-12-bookworm-v20250812"
      size  = 10
      type  = "pd-balanced"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  
}

module "vpc"{
    source = "terraform-google-modules/network/google"
    version = "11.0.0"
    project_id = "gcp-4linux"
    network_name = "cap11-network"
    subnets = [
        {
            subnet_name           = "cap11-subnet"
            subnet_ip             = "10.10.1.0/28"
            subnet_region         = "us-central1"
        }
    ]

}