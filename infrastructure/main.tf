# 1. Define the Provider (Who are we talking to?)
provider "kubernetes" {
  config_path = "C:/Users/hp/.kube/config" # This points to the "connection info" Docker Desktop created
}

# 2. Create a "Namespace" (A folder for our app inside K8s)
resource "kubernetes_namespace" "atlas_namespace" {
  metadata {
    name = "atlas-app"
  }
}

# 3. Define the "Deployment" (The blueprint for running our Docker containers)
resource "kubernetes_deployment" "atlas_deployment" {
  metadata {
    name      = "atlas-api"
    namespace = kubernetes_namespace.atlas_namespace.metadata[0].name
  }

  spec {
    replicas = 3 # Senior move: We run 3 copies so if one crashes, the app stays up!

    selector {
      match_labels = {
        app = "atlas-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "atlas-api"
        }
      }

      spec {
        container {
          image = "atlas-micro-service:latest" # We will build this next
          name  = "atlas-api-container"

          image_pull_policy = "Never"

          port {
            container_port = 3000
          }

          # Liveness probe (Kubernetes checking our /health endpoint)
          liveness_probe {
            http_get {
              path = "/health"
              port = 3000
            }
            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

# 4. Create a "Service" (The Load Balancer that gives us a URL)
resource "kubernetes_service" "atlas_service" {
  metadata {
    name      = "atlas-service"
    namespace = kubernetes_namespace.atlas_namespace.metadata[0].name
  }

  spec {
    selector = {
      app = "atlas-api"
    }

    port {
      port        = 80
      target_port = 3000
    }

    type = "LoadBalancer" # This makes the app accessible on http://localhost
  }
}