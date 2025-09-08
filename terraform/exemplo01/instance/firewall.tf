resource "google_compute_firewall" "exemplo-fw" {
  name    = "exemplo-fw"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [ "0.0.0.0/0" ]
}
