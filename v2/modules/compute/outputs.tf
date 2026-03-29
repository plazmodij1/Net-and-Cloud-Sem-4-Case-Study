output "alb_arn" {
    description = "The ARN of the ALB"
    value = aws_lb.main.arn
}

output "alb_dns_name" {
    description = "The DNS name of the ALB"
    value = aws_lb.main.dns_name
}

output "alb_public_url" {
    description = "The public URL of the ALB"
    value = "http://${aws_lb.main.dns_name}"
}

output "alb_zone_id" {
    description = "The zone ID of ALB"
    value = aws_lb.main.zone_id
}

output "lambda_function_arn" {
    description = "The ARN of the Lambda function"
    value       = aws_lambda_function.main.arn
}

output "lambda_function_id" {
    description = "ID of the Lambda function"
    value = aws_lambda_function.main.id
}

output "lambda_function_name" {
    description = "The name of the Lambda function"
    value       = aws_lambda_function.main.function_name
}

output "lambda_function_invoke_arn" {
    description = "The invoke ARN of the Lambda function"
    value       = aws_lambda_function.main.invoke_arn
}

output "lambda_target_group_arn" {
    description = "The ARN of the Lambda target group"
    value       = aws_lb_target_group.lambda_tg.arn
}

output "lambda_target_group_name" {
    description = "The name of the Lambda target group"
    value       = aws_lb_target_group.lambda_tg.name
}

output "lambda_sg_id" {
    value = aws_security_group.lambda.id
}

