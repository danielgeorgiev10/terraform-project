output "nginx_url" {
  value = "http://localhost:8080"
}

output "network_name" {
  value = docker_network.app_network.name
}

output "postgres_container_name" {
  value = docker_container.postgres.name
}