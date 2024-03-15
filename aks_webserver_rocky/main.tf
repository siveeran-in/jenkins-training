terraform {
  backend "local" {
    path = "/etc/.azure/aks.webserver.rocky.terraform.tfstate"
  }
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

provider "kubernetes" {
  config_path = "/etc/.azure/aks_config"
}

data "template_file" "prefix" {
  template = file("/etc/.azure/prefix")
}

resource "kubernetes_deployment" "example" {
  metadata {
    name = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
    labels = {
      app = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
      }
    }

    template {
      metadata {
        labels = {
          app = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
        }
      }

      spec {
        container {
          image = "smehta26/apache:rocky"
          name  = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
        }
      }
    }
  }
}

resource "kubernetes_service" "rocky" {
  metadata {
    name = "${trimspace(data.template_file.prefix.rendered)}-rocky-webserver"
  }
  spec {
    selector = {
      app = kubernetes_deployment.example.metadata.0.labels.app
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
  wait_for_load_balancer = false
}
