output "website_url" {
    description = "URL of the ALB"
    value       = module.compute.website_url
}

output "vpn_download_command" {
    description = "Download command for the VPN connection"
    value       = module.compute.vpn_download_command
}