# 1. Trust Policy (Allows ECS tasks to assume these roles)
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# 2. Execution Role (Used by the ECS agent)
resource "aws_iam_role" "task_execution" {
  name               = "ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Attach the standard AWS managed policy for execution (logging/ECR access)
resource "aws_iam_role_policy_attachment" "execution_standard" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# 3. Task Role (Used by your application code)
resource "aws_iam_role" "task_role" {
  name               = "ecs-task-application-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}