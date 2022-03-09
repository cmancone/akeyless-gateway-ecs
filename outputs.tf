output "lb_security_group_id" {
  value       = aws_security_group.lb.id
  description = "The ID of the security group for the load balancer."
}

output "ecs_tasks_security_group_id" {
  value       = aws_security_group.ecs_tasks.id
  description = "The ID of the security group for the ECS tasks."
}

output "ecs_cluster_arn" {
  value       = aws_ecs_cluster.gateway.arn
  description = "The ARN of the ECS cluster."
}
