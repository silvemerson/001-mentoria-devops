resource "google_compute_disk" "disk-backup" {
  name  = "disk-backup"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  size = 15
}