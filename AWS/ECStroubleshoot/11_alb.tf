# ------------
# ALB
# ------------
resource "aws_lb" "this" {
  name               = "${var.name}-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  depends_on         = [aws_subnet.private_a, aws_subnet.private_b, aws_security_group.alb]
}
resource "aws_alb_target_group" "web_tg" {
  name        = "ecs-web-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id 
  target_type = "ip"          

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/" 
    unhealthy_threshold = "2"
  }
}

# ------------
# Listener
# ------------
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.web_tg.arn
  }

  depends_on = [ aws_lb.this , aws_alb_target_group.web_tg ]
}
