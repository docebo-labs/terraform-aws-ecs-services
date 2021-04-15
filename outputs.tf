output "services" {
  value       = { for k, v in aws_ecs_service.ecs-service : k => v.id }
  description = "The created services IDs"
}
