resource "google_compute_instance" "exemplo_vm" {
  name         = var.vm-name
  machine_type = "f1-micro"
  zone         = "us-central1-a"


  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  attached_disk {
    source = google_compute_disk.disk-backup.id
  }

  metadata = {
    ssh-keys = "emerson:${file("~/4Linux/4labs/524/ssh-keys/524_rsa.pub")}"
  }

  # metadata_startup_script = <<-EOF
  #    #!/bin/sh
  #    sudo apt update
  #    sudo apt install nginx -y
    
  #   EOF

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

}

resource "null_resource" "install_nginx" {
  depends_on = [ google_compute_instance.exemplo_vm ]

  connection {
    type     = "ssh"
    user     = "emerson"
    private_key = file("~/4Linux/4labs/524/ssh-keys/524_rsa")
    host     = google_compute_instance.exemplo_vm.network_interface[0].access_config[0].nat_ip
  }
  provisioner "remote-exec" {
    inline = [ "sudo apt update","sudo apt install nginx -y" ]
    
  }

}
