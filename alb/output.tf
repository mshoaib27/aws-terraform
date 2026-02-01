output "alb_arn" {
  description = "ARN of the load balancer"
  value       = try(aws_lb.this[0].arn, "")
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = try(aws_lb.this[0].dns_name, "")
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = try(aws_lb_target_group.default[0].arn, "")
}

output "target_group_name" {
  description = "Name of the target group"
  value       = try(aws_lb_target_group.default[0].name, "")
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = try(aws_lb_listener.http[0].arn, "")
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = try(aws_lb_listener.https[0].arn, "")
}
