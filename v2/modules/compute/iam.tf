# IAM role for the Lambda function to allow basic execution and service access
resource "aws_iam_role" "lambda" {
  name = "${var.env}-lambda-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# Policy allowing the Lambda function to retrieve database credentials from Secrets Manager
resource "aws_iam_role_policy" "lambda_secrets" {
  name = "${var.env}-lambda-secrets-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["secretsmanager:GetSecretValue"],
      Resource = var.db_secret_arn
    }]
  })
}

# Policy allowing the Lambda function to create and write logs in CloudWatch
resource "aws_iam_role_policy" "lambda_logging" {
  name = "${var.env}-lambda-monitor-policy"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "Statement1"
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_access" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#EKS Cluster Control Role
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster_role" {
    name = "${var.env}-eks-cluster-role"
    assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json

    tags = {
        Name = "${var.env}-eks-cluster-role"
        Environment = var.env
    }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks_cluster_role.name
}

#OIDC Provider
resource "aws_iam_openid_connect_provider" "eks" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer

    tags = {
        Name = "${var.env}-eks-oidc-provider"
        Environment = var.env
    }
}

resource "aws_iam_role" "app_pod_role"{
    name = "${var.env}-portal-pod-role"
    assume_role_policy = data.aws_iam_policy_document.app_pod_assume_role.json

    tags = {
        Name = "${var.env}-eks-oidc-provider"
        Environment = var.env
    }
}

#Attach permission to read the DB Secret
resource "aws_iam_role_policy" "pod_rds_access"{
    name = "${var.env}-pod-rds-access"
    role = aws_iam_role.app_pod_role.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Action = ["secretsmanager:GetServiceValue"]
            Resource = var.db_secret_arn
        }]
    })
}

#Basic permission for nodes to function properly
resource "aws_iam_role" "eks_node_role" {
    name = "${var.env}-eks-node-role"
    assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json

    tags = {
        Name = "${var.env}-eks-oidc-provider"
        Environment = var.env
    }
}

#Attach standard AWS managed policies for EKS worker nodes
resource "aws_iam_role_policy_attachment" "eks_worker_node" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    role = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    role = aws_iam_role.eks_node_role.name
}