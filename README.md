# AWS Elastic Container Services (ECS) Terraform module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 1.0 |
| aws | ~> 3.31 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 3.31 |

## Modules

No Modules.

## Resources

| Name |
|------|
| [aws_ecs_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) |
| [aws_service_discovery_private_dns_namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) |
| [aws_service_discovery_service](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ecs\_cluster\_arn | The ARN of the ECS Cluster where these services will be created | `string` | n/a | yes |
| enable\_service\_discovery | Whether to enable service discovery for tasks | `bool` | n/a | yes |
| internal\_dns\_name | Internal DNS name, required when enabling service discovery | `string` | `""` | no |
| service\_discovery\_health\_check\_failure\_threshold | The health check failure threshold | `number` | `1` | no |
| service\_discovery\_record\_ttl | The DNS record ttl used in service discovery | `number` | `10` | no |
| service\_discovery\_record\_type | The DNS record type used in service discovery | `string` | `"A"` | no |
| service\_discovery\_routing\_policy | The routing policy used in service discovery | `string` | `"MULTIVALUE"` | no |
| services | The list of services to be created | <pre>map(object({<br>    task_definition_arn = string<br>    launch_type         = optional(string)<br>    scheduling_strategy = optional(string)<br><br>    desired_count                      = optional(number)<br>    deployment_minimum_healthy_percent = optional(number)<br>    deployment_maximum_percent         = optional(number)<br><br>    load_balancers = map(object({<br>      elb_name         = optional(string)<br>      target_group_arn = optional(string)<br>      container_name   = string<br>      container_port   = number<br>    }))<br><br>    capacity_provider_strategy = optional(object({<br>      base              = optional(number)<br>      capacity_provider = string<br>      weight            = optional(number)<br>    }))<br><br>    deployment_circuit_breaker = optional(object({<br>      enable   = bool<br>      rollback = bool<br>    }))<br><br>    deployment_controller = optional(object({<br>      type = optional(string)<br>    }))<br><br>    placement_constraints = map(object({<br>      type       = string<br>      expression = optional(string)<br>    }))<br><br>    ordered_placement_strategies = map(object({<br>      type  = string<br>      field = optional(string)<br>    }))<br><br>    network_configuration = optional(object({<br>      subnets          = list(string)<br>      security_groups  = list(string)<br>      assign_public_ip = optional(bool)<br>    }))<br>  }))</pre> | n/a | yes |
| vpc\_id | The VPC identifier | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| services | The created services IDs |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
