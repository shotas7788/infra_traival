resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/traival"
  retention_in_days = 180
}

resource "aws_cloudwatch_log_group" "for_ecs_scheduled_tasks" {
  name              = "/ecs-scheduled-tasks/traival"
  retention_in_days = 180
}

resource "aws_cloudwatch_event_rule" "traival_batch" {
  name                = "traival-batch"
  description         = "とても重要なバッチ処理です"
  schedule_expression = "cron(*/2 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "traival_batch" {
  target_id = "traival-batch"
  rule      = aws_cloudwatch_event_rule.traival_batch.name
  role_arn  = module.ecs_events_role.iam_role_arn
  arn       = aws_ecs_cluster.traival.arn

  ecs_target {
    launch_type         = "FARGATE"
    task_count          = 1
    platform_version    = "1.3.0"
    task_definition_arn = aws_ecs_task_definition.traival_batch.arn

    network_configuration {
      assign_public_ip = "false"
      subnets          = [aws_subnet.private_0.id]
    }
  }
}

resource "aws_cloudwatch_log_group" "operation" {
  name              = "/operation"
  retention_in_days = 180
}
