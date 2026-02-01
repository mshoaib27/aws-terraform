resource "aws_lb" "this" {
  count               = var.create_alb ? 1 : 0
  name                = var.alb_name
  internal            = var.internal
  load_balancer_type  = "application"
  security_groups     = var.security_groups
  subnets = var.public_subnets
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
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
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

######################### ALB Target Group Registration #########################
resource "aws_lb_target_group_attachment" "ec2_target" {
  count            = var.create_alb && var.register_targets ? 1 : 0
  target_group_arn = aws_lb_target_group.default[0].arn
  target_id        = var.target_instance_id
  port             = 80
}

######################### ALB Listener - HTTPS #########################
resource "aws_lb_listener" "https" {
  count             = var.create_alb && var.ssl_certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.this[0].arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[0].arn
  }
}