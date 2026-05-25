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
output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.compute.cognito_user_pool_id
}

output "ecr_repository_url" {
  value = module.compute.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.compute.ecs_cluster_name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = module.compute.ecs_service_name
}