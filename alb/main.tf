resource "aws_lb" "this" {
  count               = var.create_alb ? 1 : 0
  name                = var.alb_name
  internal            = var.internal
  load_balancer_type  = "application"
  security_groups     = var.security_groups
  subnets             = var.subnets
  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.tags, {
    Name = var.alb_name
  })
}

resource "aws_lb_listener" "http" {
  count           = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port            = 80
  protocol        = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Default action"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "default" {
  count      = var.create_alb ? 1 : 0
  name       = "${var.alb_name}-tg"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = merge(var.tags, {
    Name = "${var.alb_name}-tg"
  })
}