output "website_url" {
    description = "The public URL of your Application Load Balancer"
    value       = "http://${aws_lb.main.dns_name}"
}

output "vpn_download_command" {
    value = "scp -i your-aws-ssh-key-name.pem ubuntu@${aws_instance.vpn.public_ip}:~/mylaptop.conf ./"
}

output "rds_proxy_endpoint" {
    value = aws_db_proxy.main.endpoint 
}