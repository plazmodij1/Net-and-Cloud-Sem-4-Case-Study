output "sns_topic_arn" {
    value = aws_sns_topic.waf_alerts.arn
}

output "cloudwatch_log_group_arn" {
    value = aws_cloudwatch_log_group.waf_log_group.arn
}