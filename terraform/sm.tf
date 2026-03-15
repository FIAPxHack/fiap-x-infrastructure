resource "random_password" "grafana_admin" {
  length  = 20
  special = true
}

resource "aws_secretsmanager_secret" "grafana_admin" {
  name                    = "${var.project_name}-grafana-admin-password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "grafana_admin" {
  secret_id     = aws_secretsmanager_secret.grafana_admin.id
  secret_string = jsonencode({
    password = random_password.grafana_admin.result
  })
}