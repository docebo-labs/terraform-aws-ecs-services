variable "vpc_id" {
  type        = string
  description = "The VPC identifier"

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "Wrong value for variable vpc_id."
  }
}

variable "ecs_cluster_arn" {
  type        = string
  description = "The ARN of the ECS Cluster where these services will be created"

  validation {
    condition     = can(regex("^arn:aws:ecs:\\w{2}-\\w+-[[:digit:]]:[[:digit:]]+:cluster/.+$", var.ecs_cluster_arn))
    error_message = "Invalid ARN passed."
  }
}

variable "enable_service_discovery" {
  type        = bool
  description = "Whether to enable service discovery for tasks"
}

variable "service_discovery_routing_policy" {
  type        = string
  description = "The routing policy used in service discovery"
  default     = "MULTIVALUE"
}

variable "service_discovery_record_type" {
  type        = string
  description = "The DNS record type used in service discovery"
  default     = "A"
}

variable "service_discovery_record_ttl" {
  type        = number
  description = "The DNS record ttl used in service discovery"
  default     = 10
}

variable "service_discovery_health_check_failure_threshold" {
  type        = number
  description = "The health check failure threshold"
  default     = 1

  validation {
    condition     = var.service_discovery_health_check_failure_threshold <= 10
    error_message = "Maximum threshold value is 10."
  }
}

variable "internal_dns_name" {
  type        = string
  description = "Internal DNS name, required when enabling service discovery"
  default     = ""
}

variable "services" {
  type = map(object({
    task_definition_arn = string
    launch_type         = optional(string)

    desired_count                      = optional(number)
    deployment_minimum_healthy_percent = optional(number)
    deployment_maximum_percent         = optional(number)

    load_balancers = map(object({
      elb_name         = optional(string)
      target_group_arn = optional(string)
      container_name   = string
      container_port   = number
    }))

    capacity_provider_strategy = optional(object({
      base              = optional(number)
      capacity_provider = string
      weight            = optional(number)
    }))

    deployment_circuit_breaker = optional(object({
      enable   = bool
      rollback = bool
    }))

    deployment_controller = optional(object({
      type = optional(string)
    }))

    network_configuration = optional(object({
      subnets          = list(string)
      security_groups  = list(string)
      assign_public_ip = optional(bool)
    }))
  }))
  description = "The list of services to be created"

  validation {
    condition     = alltrue([for k, s in var.services : contains(["FARGATE", "EC2"], s.launch_type)])
    error_message = "Invalid launch type passed."
  }
}
