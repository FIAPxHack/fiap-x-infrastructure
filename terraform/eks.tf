# ==========================================
# EKS CLUSTER IAM ROLE
# ==========================================
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ==========================================
# EKS CLUSTER
# ==========================================
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks-${var.environment}"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.31"

  vpc_config {
    subnet_ids              = data.aws_subnets.default.ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = {
    Name        = "${var.project_name}-eks-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# EKS NODE GROUP IAM ROLE
# ==========================================
resource "aws_iam_role" "eks_nodes" {
  name = "${var.project_name}-eks-nodes-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# ==========================================
# EKS MANAGED NODE GROUP
# ==========================================
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-nodes-${var.environment}"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = data.aws_subnets.default.ids

  instance_types = [var.eks_node_instance_type]

  scaling_config {
    desired_size = var.eks_node_desired
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.eks_ecr_read,
  ]

  tags = {
    Name        = "${var.project_name}-nodes-${var.environment}"
    Environment = var.environment
  }
}

# ==========================================
# OIDC PROVIDER (para IRSA - IAM Roles for Service Accounts)
# ==========================================
data "aws_eks_cluster" "main" {
  name       = aws_eks_cluster.main.name
  depends_on = [aws_eks_cluster.main]
}

data "tls_certificate" "eks" {
  url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name        = "${var.project_name}-eks-oidc-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = "aws-ebs-csi-driver"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.main,
    aws_iam_role_policy_attachment.ebs_csi
  ]
}