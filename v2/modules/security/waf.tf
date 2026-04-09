resource "aws_wafv2_web_acl" "alb_waf" {
    name = "${var.env}-waf-alb"
    scope = "REGIONAL"

    default_action {
        allow {}
    }
    
    rule {
        name = "RateLimitSpamIPs"
        priority = 1

        action {
            block {}
        }
        
        statement {
            rate_based_statement {
                limit = var.rate_limit
                aggregate_key_type = "IP"
            }
        }

        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "RateLimitSpamIPsMetric"
            sampled_requests_enabled = true
        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "WAFGlobalMetrics"
        sampled_requests_enabled = true
    }
}

resource "aws_cloudwatch_log_group" "waf_log_group" {
    name = "aws-waf-logs-${var.env}-alb"
    retention_in_days = 7
}

resource "aws_wafv2_web_acl_association" "alb" {
    resource_arn = var.alb_arn
    web_acl_arn = aws_wafv2_web_acl.alb_waf.arn
} 

resource "aws_wafv2_web_acl_logging_configuration" "waf_logs" {
    log_destination_configs = [aws_cloudwatch_log_group.waf_log_group.arn]
    resource_arn = aws_wafv2_web_acl.alb_waf.arn
}

resource "aws_cloudwatch_log_subscription_filter" "waf_log_filter" {
    name = "${var.env}-waf-block-filter"
    log_group_name = aws_cloudwatch_log_group.waf_log_group.name
    filter_pattern = "{ $.action = \"BLOCK\" }"
    destination_arn = aws_lambda_function.soar_brain.arn
    depends_on = [aws_lambda_permission.allow_cloudwatch]
}