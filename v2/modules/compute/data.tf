data "aws_caller_identity" "current" {}

data "tls_certificate" "eks"{
    url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

#Only pods using "portal-sa" can assume this role to fetch DB credentials
data "aws_iam_policy_document" "app_pod_assume_role" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type = "Federated"
        identifiers = [aws_iam_openid_connect_provider.eks.arn]
      }
      condition {
        test = "StringEquals"
        variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
        values = ["system:serviceaccount:default:portal-sa"]
      }
    }
}

#Basic permission for nodes to function properly
data "aws_iam_policy_document" "eks_node_assume_role" {
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type = "Service"
        identifiers = ["ec2.amazonaws.com"]
      }
    }
}