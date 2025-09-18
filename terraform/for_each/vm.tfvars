instances = {
  "mysql" = {
    machine_type = "f1-micro"
    zone         = "us-central1-a"
    size         = 10
    image        = "debian-cloud/debian-11"

  }
  "nginx" = {
    machine_type = "e2-medium"
    zone         = "us-central1-b"
    size         = 50
    image        = "debian-cloud/debian-12"
  }

  "grafana" = {
    machine_type = "e2-small"
    zone         = "us-central1-c"
    size         = 20
    image        = "debian-cloud/debian-11"
  }

  "jenkins" = {
    machine_type = "e2-medium"
    zone         = "us-central1-a"
    size         = 30
    image        = "debian-cloud/debian-11"
  }
}