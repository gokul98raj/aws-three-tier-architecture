resource "aws_alb" "alb_main" {
  name               = "main_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  tags               = { Name = "alb_main" }

  access_logs {
    bucket = aws_s3_bucket.s3_logs.bucket
    prefix = "alb_logs"
  }
}

resource "aws_lb_target_group" "alb_target_group_main" {
  name     = "main_target_group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id
  tags     = { Name = "alb_target_group_main" }

}

resource "aws_lb_listener" "aws_lb_listener_main" {
  load_balancer_arn = aws_alb.alb_main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group_main.arn
  }

}