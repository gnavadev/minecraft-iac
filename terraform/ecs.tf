data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_ecs_cluster" "minecraft" {
  name = "${var.project_name}-cluster"
}

resource "aws_cloudwatch_log_group" "minecraft" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "minecraft" {
  family                   = var.project_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = data.aws_iam_role.lab_role.arn
  task_role_arn            = data.aws_iam_role.lab_role.arn

  container_definitions = jsonencode([
    {
      name      = "minecraft-server"
      image     = "itzg/minecraft-server:latest"
      essential = true

      environment = [
        { name = "EULA", value = "TRUE" },   # replaces the manual eula.txt edit
        { name = "TYPE", value = "VANILLA" },
        { name = "MEMORY", value = "2G" }    # JVM heap; leaves headroom in the 3 GiB task
      ]

      portMappings = [
        {
          containerPort = var.minecraft_port
          hostPort      = var.minecraft_port
          protocol      = "tcp"
        }
      ]

      mountPoints = [
        {
          sourceVolume  = "minecraft-data"
          containerPath = "/data" # itzg image stores world + configs here
          readOnly      = false
        }
      ]

      stopTimeout = 120

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.minecraft.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "minecraft"
        }
      }
    }
  ])

  volume {
    name = "minecraft-data"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.minecraft_data.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.minecraft_data.id
        iam             = "ENABLED"
      }
    }
  }
}

resource "aws_ecs_service" "minecraft" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.minecraft.id
  task_definition = aws_ecs_task_definition.minecraft.arn
  desired_count   = 1 # ECS auto-restarts the server if it dies
  launch_type     = "FARGATE"

  # Critical with a shared EFS world: never run two servers at once.
  # The old task must stop (and save) before the new one starts.
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.minecraft.id]
    assign_public_ip = true
  }

  depends_on = [aws_efs_mount_target.minecraft_data]
}
