terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "docker" {}

resource "docker_network" "app_network" {
  name = "app-network"
}

resource "docker_image" "nginx" {
  name = "my-nginx:v1"

  build {
    context = "${path.cwd}/app"
  }
}

resource "docker_image" "postgres" {
  name = "postgres:15"
}

resource "docker_container" "postgres" {
  name  = "postgres-db"
  image = docker_image.postgres.image_id

  env = [
  "POSTGRES_USER=${var.postgres_user}",
  "POSTGRES_PASSWORD=${var.postgres_password}",
  "POSTGRES_DB=${var.postgres_db}"
]

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
  volume_name    = docker_volume.postgres_data.name
  container_path = "/var/lib/postgresql/data"
}
}

resource "docker_container" "nginx" {
  count = var.nginx_replicas

  name  = "app-nginx-${count.index}"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

}

resource "docker_volume" "postgres_data" {
  name = "postgres_data"
}

resource "local_file" "lb_config" {
  filename = "${path.cwd}/lb.conf"

  content = templatefile(
    "${path.cwd}/lb.conf.tpl",
    {
      servers = local.nginx_servers
    }
  )
}

resource "docker_image" "nginx_lb" {
  name = "nginx:latest"
}

resource "docker_container" "lb" {
  name  = "nginx-lb"
  image = docker_image.nginx_lb.image_id

  ports {
    internal = 80
    external = 8080
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    host_path      = "${path.cwd}/lb.conf"
    container_path = "/etc/nginx/conf.d/default.conf"
  }

  depends_on = [
  docker_container.nginx,
  local_file.lb_config
]
}