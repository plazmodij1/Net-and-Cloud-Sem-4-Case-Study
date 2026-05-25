output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_id" {
  description = "ID of the Lambda function"
  value       = aws_lambda_function.main.id
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_invoke_arn" {
  description = "The invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}

output "website_url" {
  description = "The public URL of your Application Load Balancer"
  value       = "http://${aws_lb.main.dns_name}"
}

output "vpn_download_command" {
  value = "scp -i your-aws-ssh-key-name.pem ubuntu@${aws_instance.vpn.public_ip}:~/mylaptop.conf ./"
}

output "alb_arn" {
  value = aws_lb.main.arn
}

output "ecs_portal_sg_id" {
  value = aws_security_group.ecs_portal.id
}

output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.portal_users.id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.portal_repo.repository_url
}

output "k8s_internal_ip" {
  value = aws_instance.k8s_node.private_ip
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.portal.name
}