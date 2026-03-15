resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.10.2"
  namespace        = "monitoring"
  create_namespace = true

  depends_on = [helm_release.prometheus]

  timeout = 300
  wait    = false

  values = [
    yamlencode({
      loki = {
        enabled = true

        persistence = {
          enabled = false
        }

        config = {
          limits_config = {
            retention_period = "24h"
          }
          table_manager = {
            retention_deletes_enabled = true
            retention_period          = "24h"
          }
        }

        resources = {
          requests = { cpu = "100m", memory = "128Mi" }
          limits   = { cpu = "300m", memory = "512Mi" }
        }
      }

      promtail = {
        enabled = true

        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "100m", memory = "128Mi" }
        }

        config = {
          clients = [
            {
              url = "http://loki:3100/loki/api/v1/push"
            }
          ]
        }
      }

      grafana = {
        enabled = false
      }
    })
  ]
}