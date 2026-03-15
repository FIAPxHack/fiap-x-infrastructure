resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki-stack"
  version          = "2.10.2"
  namespace        = "monitoring"
  create_namespace = true

  # Loki deve subir depois que o namespace já foi criado pelo Prometheus
  depends_on = [helm_release.prometheus]

  timeout = 300

  values = [
    yamlencode({
      # ==========================================
      # LOKI
      # ==========================================
      loki = {
        enabled = true

        # Persistência para não perder logs ao reiniciar o pod
        persistence = {
          enabled      = true
          storageClass = "gp2"
          size         = "512Mi"
        }

        # Retenção de logs: 1 dia
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

      # ==========================================
      # PROMTAIL — agente coletor de logs nos nodes
      # ==========================================
      promtail = {
        enabled = true

        # Recursos do DaemonSet do Promtail
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

      # Grafana desabilitado aqui — já existe um no kube-prometheus-stack
      grafana = {
        enabled = false
      }
    })
  ]
}