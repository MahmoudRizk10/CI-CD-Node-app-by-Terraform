resource "aws_ecs_cluster" "FS_cluster" {
  name = var.cluster_name
  capacity_providers = [aws_ecs_capacity_provider.FS.name]
}
resource "aws_iam_service_linked_role" "ecs" {
  aws_service_name = "ecs.amazonaws.com"
}
resource "aws_ecs_capacity_provider" "FS" {
  name = "capacity-provider-FS"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
    }
  }
}

# update file container-def, so it's pulling image from ecr

resource "aws_ecs_task_definition" "task-definition-test" {
  family                = "web-family"
  container_definitions = file("container-definitions/container-def.json")
  network_mode          = "bridge"
  tags = {
    "env"       = "dev"
  }
}
resource "aws_ecs_service" "service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.FS_cluster.id
  task_definition = aws_ecs_task_definition.task-definition-test.arn
  desired_count   = 10
  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = "FS-devops"
    container_port   = 80
  }
}
resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/frontend-container"
  tags = {
    "env"       = "dev"
  }
}