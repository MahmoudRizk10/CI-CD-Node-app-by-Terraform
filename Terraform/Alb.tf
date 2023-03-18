resource "aws_security_group" "lb" {
  name   = "allow-all-lb"
  vpc_id = aws_vpc.FS_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "env"       = "dev"
  }
}
resource "aws_lb" "FS-lb" {
  name               = "FS-ecs-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = [ aws_subnet.FS_subnet.id, aws_subnet.FS_subnet_2.id]
  tags = {
    "env"       = "dev"
  }
  security_groups = [aws_security_group.lb.id]
}
resource "aws_lb_target_group" "lb_target_group" {
  name        = "FS-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.FS_vpc.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}
resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.FS-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}