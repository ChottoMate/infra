data "aws_region" "current" {}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.env}-${var.name}"
  retention_in_days = 14
  tags              = merge(var.tags, { Name = "${var.env}-${var.name}-logs" })
}

resource "aws_ecs_cluster" "this" {
  name = "${var.env}-${var.name}-cluster"
  tags = var.tags
}

resource "aws_security_group" "svc" {
  name        = "${var.env}-${var.name}-sg"
  description = "ECS service sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = var.tags
}

resource "aws_iam_role" "task" {
  name               = "${var.env}-${var.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}
data "aws_iam_policy_document" "task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy" "exec_logs" {
  name = "allow-logs"
  role = aws_iam_role.exec.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role" "exec" {
  name               = "${var.env}-${var.name}-exec"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
  tags               = var.tags
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env}-${var.name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.exec.arn
  task_role_arn            = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name         = var.name
    image        = var.image
    essential    = true
    portMappings = [{ containerPort = var.container_port }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.this.name
        awslogs-region        = data.aws_region.current.name
        awslogs-stream-prefix = "app"
      }
    }
  }])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = var.tags
}

resource "aws_ecs_service" "this" {
  name            = "${var.env}-${var.name}"
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  desired_count   = var.desired_count
  task_definition = aws_ecs_task_definition.this.arn
  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [aws_security_group.svc.id]
    assign_public_ip = true
  }
  tags = var.tags
}
