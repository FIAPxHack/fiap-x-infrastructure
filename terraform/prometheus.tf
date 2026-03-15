resource "helm_release" "prometheus" {
  name             = "kube-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.2.2"
  namespace        = "monitoring"
  create_namespace = true

  # Aguarda os nodes estarem prontos antes de instalar
  depends_on = [aws_eks_node_group.main]

  # Tempo máximo de espera para o deploy estabilizar
  timeout = 900

  values = [
    yamlencode({
      # ==========================================
      # GRAFANA
      # ==========================================
      grafana = {
        enabled = true

        adminPassword = random_password.grafana_admin.result

        # Persistência para não perder dashboards ao reiniciar o pod
        persistence = {
          enabled      = true
          storageClass = "gp2"
          size         = "512Mi"
        }

        # Expõe o Grafana via LoadBalancer para acesso externo
        service = {
          type = "LoadBalancer"
        }

        # Recursos adequados para t3.small
        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "100m", memory = "128Mi" }
        }

        # Data source do Loki pré-configurado
        additionalDataSources = [
          {
            name   = "Loki"
            type   = "loki"
            url    = "http://loki:3100"
            access = "proxy"
          }
        ]
      }

      # ==========================================
      # PROMETHEUS
      # ==========================================
      prometheus = {
        prometheusSpec = {
          # Retenção de 1 dia de métricas
          retention = "1d"

          # Persistência do Prometheus no EBS
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "gp2"
                accessModes      = ["ReadWriteOnce"]
                resources = {
                  requests = { storage = "512Mi" }
                }
              }
            }
          }

          # Recursos adequados para t3.small
          resources = {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "100m", memory = "256Mi" }
          }

          # Permite descobrir ServiceMonitors de qualquer namespace
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
        }
      }

      # ==========================================
      # ALERTMANAGER
      # ==========================================
      alertmanager = {
        alertmanagerSpec = {
          resources = {
            requests = { cpu = "25m", memory = "32Mi" }
            limits   = { cpu = "50m", memory = "64Mi" }
          }
        }
      }
    })
  ]
}