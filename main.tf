terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_service_discovery_private_dns_namespace" "this" {
  count       = var.enable_service_discovery ? 1 : 0
  name        = var.internal_dns_name
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  for_each = var.enable_service_discovery ? var.services : {}
  name     = lower(each.key)

  dns_config {
    namespace_id = element(aws_service_discovery_private_dns_namespace.this.*.id, 0)

    dns_records {
      ttl  = var.service_discovery_record_ttl
      type = var.service_discovery_record_type
    }

    routing_policy = var.service_discovery_routing_policy
  }

  health_check_custom_config {
    failure_threshold = var.service_discovery_health_check_failure_threshold
  }
}

resource "aws_ecs_service" "ecs-service" {
  for_each = var.services

  name            = each.key
  cluster         = var.ecs_cluster_arn
  task_definition = each.value.task_definition_arn
  launch_type     = each.value.launch_type

  desired_count                      = each.value.desired_count
  deployment_minimum_healthy_percent = each.value.deployment_minimum_healthy_percent
  deployment_maximum_percent         = each.value.deployment_maximum_percent

  dynamic "load_balancer" {
    for_each = each.value.load_balancers

    content {
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
      elb_name         = load_balancer.value.elb_name
      target_group_arn = load_balancer.value.target_group_arn
    }
  }

  dynamic "placement_constraints" {
    for_each = each.value.placement_constraints

    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  dynamic "ordered_placement_strategy" {
    for_each = each.value.ordered_placement_strategies

    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  dynamic "service_registries" {
    for_each = var.enable_service_discovery ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.this[each.key].arn
    }
  }

  dynamic "network_configuration" {
    for_each = each.value.network_configuration != null ? [1] : []

    content {
      subnets          = each.value.network_configuration.subnets
      security_groups  = each.value.network_configuration.security_groups
      assign_public_ip = each.value.network_configuration.assign_public_ip
    }
  }
}
