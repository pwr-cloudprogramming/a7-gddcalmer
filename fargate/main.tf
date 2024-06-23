
provider "aws" {
  region = "us-east-1"
}

data "aws_iam_role" "existing_role" {
  name = "LabRole"
}


resource "aws_ecs_cluster" "default" {
  name = "your-ecs-cluster-name"
  // Add other configurations as needed
}

resource "aws_ecs_service" "tic_tac_toe_service" {
  name                               = "app_TicTacToe_Service_backend"
  cluster                            = aws_ecs_cluster.default.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = 1
  enable_ecs_managed_tags = true
  wait_for_steady_state   = true
  deployment_minimum_healthy_percent = 50  # Example minimum healthy percent
  deployment_maximum_percent         = 200  # Example maximum percent
  launch_type                        = "FARGATE"



  network_configuration {
    security_groups  = [aws_security_group.ecs_container_instance.id]
    subnets          = ["subnet-0f35fd16f743f614f" , "subnet-0337b00a91569670d"]
    assign_public_ip = true
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}



## Creates ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "app_ECS_TaskDefinition_app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = data.aws_iam_role.existing_role.arn
  task_role_arn            = data.aws_iam_role.existing_role.arn
  cpu                      = 512
  memory                   = 1024
  
  container_definitions = jsonencode([
    {
      name           = "backend"
      image          = "685117888313.dkr.ecr.us-east-1.amazonaws.com/tictactoe:v1"
      cpu            = 512
      memory         = 1024
      essential      = true
      portMappings   = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options   = {
          "awslogs-group"         = aws_cloudwatch_log_group.log_backend.name,
          "awslogs-region"        = "us-east-1",
          "awslogs-stream-prefix" = "app-log-stream-backend"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "log_backend" {
  name              = "app-log-stream-backend" // Replace with your desired name
  retention_in_days = 30 // Specify the retention period for the logs (optional)
}

## Security Group for ECS Task Container Instances (managed by Fargate)
resource "aws_security_group" "ecs_container_instance" {
  name        = "app_ECS_Task_SecurityGroup_backend"
  description = "Security group for ECS task running on Fargate"
  vpc_id      = "vpc-0337911341b5e9991"

  ingress {
    description     = "Allow ingress traffic on 8080 only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }



  egress {
    description = "Allow all egress traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app_ECS_Task_SecurityGroup_backend"
  }
  }

