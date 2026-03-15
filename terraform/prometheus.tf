resource "helm_release" "prometheus" {
  name             = "kube-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.2.2"
  namespace        = "monitoring"
  create_namespace = true

  # Aguarda os nodes E o EBS CSI driver estarem prontos
  depends_on = [aws_eks_node_group.main, aws_eks_addon.ebs_csi]

  # Tempo máximo de espera para o deploy estabilizar
  timeout = 900

  values = [
    yamlencode({
      grafana = {
        enabled = true

        adminPassword = random_password.grafana_admin.result

        persistence = {
          enabled      = true
          storageClass = "gp2"
          size         = "512Mi"
        }

        service = {
          type = "LoadBalancer"
        }

        resources = {
          requests = { cpu = "50m", memory = "64Mi" }
          limits   = { cpu = "100m", memory = "128Mi" }
        }

        additionalDataSources = [
          {
            name   = "Loki"
            type   = "loki"
            url    = "http://loki:3100"
            access = "proxy"
          }
        ]
      }

      prometheus = {
        prometheusSpec = {
          retention = "1d"

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

          resources = {
            requests = { cpu = "50m", memory = "128Mi" }
            limits   = { cpu = "100m", memory = "256Mi" }
          }

          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues     = false
        }
      }

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