resource "aws_eks_cluster" "main" {
    name = var.eks_cluster_name
    role_arn = aws_iam_role.eks_cluster_role.arn

    vpc_config {
      subnet_ids = [var.eks_private_subnet]
      endpoint_private_access = true
      endpoint_public_access = true 
    }

    tags = {
        Name        = "${var.env}-cluster"
        Environment = var.env
    }
}

resource "aws_eks_node_group" "spot_nodes" {
    cluster_name = aws_eks_cluster.main.name
    node_group_name = "${var.env}-spot-nodes"
    node_role_arn = aws_iam_role.eks_cluster_role.arn
    subnet_ids = [var.eks_private_subnet]

    capacity_type = "SPOT"
    instance_types = ["t3.medium", "t3a.medium"]

    scaling_config {
      desired_size = 2
      max_size = 4
      min_size = 1
    }

    update_config {
      max_unavailable = 1
    }

    tags = {
        Name        = "${var.env}-cluster"
        Environment = var.env
    }

    depends_on = [
        aws_iam_role_policy_attachment.eks_worker_node,
        aws_iam_role_policy_attachment.eks_cni_policy,
        aws_iam_role_policy_attachment.eks_ecr_read,
    ]
}
