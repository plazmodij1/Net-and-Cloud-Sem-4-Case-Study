output "website_url" {
    description = "URL of the ALB"
    value       = module.compute.website_url
}

output "vpn_download_command" {
    description = "Download command for the VPN connection"
    value       = module.compute.vpn_download_command
}

output "alb_arn" {
    description = "Download command for the VPN connection"
    value       = module.compute.alb_arn
}

output "eks_cluster_name" {
    description = "Name of the EKS cluster"
    value = module.compute.eks_cluster_name
}
