resource "aws_ecs_cluster" "traival" {
    name = "traival"
}

resource "aws_ecs_task_definition" "traival" {
  family                   = "traival"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

resource "aws_ecs_service" "traival" {
    name = "traival"
    cluster = aws_ecs_cluster.traival.arn
    task_definition = aws_ecs_task_definition.traival.arn
    desired_count = 2
    launch_type = "FARGATE"
    platform_version = "1.3.0"
    health_check_grace_period_seconds = 60

    network_configuration {
        assign_public_ip = false
        security_groups = [module.nginx_sg.security_group_id]

        subnets = [
            aws_subnet.private_0.id,
            aws_subnet.private_1.id,
        ]
    }

    load_balancer {
        target_group_arn = aws_lb_target_group.traival.arn
        container_name = "traival"
        container_port = 80
    }

    lifecycle {
        ignore_changes = [task_definition]
    }
}

module "nginx_sg" {
    source = "./security_group"
    name = "nginx-sg"
    vpc_id = aws_vpc.traival.id
    port = 80
    cidr_blocks = [aws_vpc.traival.cidr_block]
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_ecs_task_definition" "traival_batch" {
  family                   = "traival-batch"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./batch_container_definitions.json")
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

module "ecs_events_role" {
  source     = "./iam_role"
  name       = "ecs-events"
  identifier = "events.amazonaws.com"
  policy     = data.aws_iam_policy.ecs_events_role_policy.policy
}

data "aws_iam_policy" "ecs_events_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceEventsRole"
}