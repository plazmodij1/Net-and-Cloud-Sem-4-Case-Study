output "website_url" {
    description = "Application Load Balancer ARN"
    value       = module.compute.website_url
}

output "vpn_download_command" {
    description = "Application Load Balancer ARN"
    value       = module.compute.vpn_download_command
}