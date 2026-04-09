resource "aws_sns_topic" "waf_alerts" {
    name = "${var.env}-waf-spam-alerts"
}

resource "aws_sns_topic_subscription" "email_v2" {
    topic_arn = aws_sns_topic.waf_alerts.arn
    protocol = "email"
    endpoint = var.email
}
