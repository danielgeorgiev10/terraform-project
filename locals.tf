locals {
  nginx_servers = [
    for i in range(var.nginx_replicas) :
    "app-nginx-${i}"
  ]
}