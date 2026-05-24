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

output "ecs_portal_sg_id" {
    value = module.compute.ecs_portal_sg_id
    }

output "eks-portal-subnets" {
    description = "Private subnets passed through from the networking layer"
    value = data.terraform_remote_state.networking.outputs.eks-portal-subnets
}