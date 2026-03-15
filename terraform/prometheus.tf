resource "helm_release" "prometheus" {
  name             = "kube-prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.2.2"
  namespace        = "monitoring"
  create_namespace = true

  depends_on = [aws_eks_node_group.main]

  timeout = 900
  wait    = false

  values = [
    yamlencode({
      grafana = {
        enabled = true

        adminPassword = random_password.grafana_admin.result

        persistence = {
          enabled = false
        }

        service = {
          type = "ClusterIP"
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