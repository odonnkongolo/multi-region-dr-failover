# 1. The Global Health Check (Pings Ireland from around the world)
resource "aws_route53_health_check" "primary_site" {
  fqdn              = aws_s3_bucket_website_configuration.primary.website_endpoint
  port              = 80
  type              = "HTTP"
  resource_path     = "/index.html"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "Primary-Region-Health"
  }
}

# 2. The SRE Alarm (Triggers if the site goes down)
resource "aws_cloudwatch_metric_alarm" "failover_alarm" {
  alarm_name          = "CRITICAL-Primary-Site-Offline"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "1"
  alarm_description   = "Monitors the Ireland endpoint. If 0, site is offline and Failover must initiate."

  dimensions = {
    HealthCheckId = aws_route53_health_check.primary_site.id
  }
}