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