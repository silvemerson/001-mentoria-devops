variable "vpc-nome" {
    description = "Nome da VPC"
    type        = string
    default     = "vpc-modulo"
  
}

variable "id-project_id" {
    description = "ID do projeto GCP"
    type        = string
    default     = "gcp-4linux"
  
}

variable "auto-vpc" {
    description = "Se a VPC é auto mode"
    type        = bool
    default     = true
  
}