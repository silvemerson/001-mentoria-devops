variable "instances" {
  type = map(object({
    machine_type = string
    zone         = string
    size         = number
    image        = string
  }))
}