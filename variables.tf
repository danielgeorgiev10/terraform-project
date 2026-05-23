variable "nginx_port" {
  type    = number
  default = 8080
}

variable "postgres_user" {
  type    = string
  default = "admin"
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db" {
  type    = string
  default = "myapp"
}

variable "nginx_replicas" {
  default = 2
}