# Security group for ALB
resource "aws_security_group" "allow_http" {
  name        = "ALB-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ALB-sg"
  }
}

# ALB
resource "aws_lb" "pub-alb" {
  name               = "pub-alb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  
  subnet_mapping {
    subnet_id     = aws_subnet.public1.id
  }
    subnet_mapping {
    subnet_id     = aws_subnet.public2.id
  }
 #Manually update required for subnet id 
 #subnets = ["subnet-08315013c61b77944","subnet-0d3aa81da4a4f90b5"]
  # subnets            = ["aws_subnet.public1.arn","aws_subnet.public2.arn"]
  # subnets = aws_subnet.public.*.id
  # depends_on = [aws_subnet.public1,aws_subnet.public2]

  enable_deletion_protection = false

#   access_logs {
#     bucket  = aws_s3_bucket.lb_logs.bucket
#     prefix  = "test-lb"
#     enabled = true
#   }

  tags = {
    Environment = "production"
  }
}

# Listeners

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.pub-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg1.arn
  }
  depends_on = [aws_lb_target_group.tg1]
}

# Target Group

resource "aws_lb_target_group" "tg1" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dev.id

  health_check {
    healthy_threshold   = 2  
    unhealthy_threshold = 5    
    timeout             = 5    
    interval            = 10    
    path                = "/index.html"    
    port                = "traffic-port"  
  }
}

# Target group attachment

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.tg1.arn
  target_id        = aws_instance.pvtserver.id
  port             = 80
}

