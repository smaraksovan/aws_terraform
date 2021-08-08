#jumpserver securitygroup
resource "aws_security_group" "allow_tls" {
  name        = "Pub-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "Allow ssh and http traffic from internet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   ingress {
    description      = "Allow ssh and http traffic from internet"
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
    Name = "allow_tls"
  }
}

#private securitygroup

resource "aws_security_group" "pvt_sg" {
  name        = "pvt-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["12.0.1.0/24","12.0.3.0/24"]
    # security_groups  = ["aws_security_group.allow_http.id"]
    # ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "Allow ssh and http traffic from internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["12.0.1.0/24","12.0.3.0/24","12.0.2.0/24"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    # ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "terraform-pvt-sg"
  }
}


#jumpbox server

resource "aws_instance" "example" {
  ami           = var.image_id
  count=1
  key_name = var.keyname
  instance_type = var.instancetype
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id              = aws_subnet.public1.id
  user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install httpd -y
    cd /var/www/html
    echo " Webserver-1 using Terraform " > index.html
    service httpd start
    chkconfig httpd on
  EOF

  tags = {
    Terraform   = true
    Name = "terraform-test"
  }
}

#private server

resource "aws_instance" "pvtserver" {
  ami           = var.image_id
  # count=1
  key_name = var.keyname
  instance_type = var.instancetype
  vpc_security_group_ids = [aws_security_group.pvt_sg.id]
  subnet_id              = aws_subnet.dev_pvt.id
  user_data = <<-EOF
    #!/bin/bash
    sudo su
    yum update -y
    yum install httpd -y
    cd /var/www/html
    echo " Webserver-1 using Terraform " > index.html
    service httpd start
    chkconfig httpd on
  EOF

  tags = {
    Terraform   = true
    Name = "private-server"
  }
}

#ebs volume creation

resource "aws_ebs_volume" "pvtserverebs" {
  availability_zone = var.pvtsubnet1_az
  size              = var.ebssize
  type = var.ebstype
}
#ebs volume attachment

resource "aws_volume_attachment" "pvt_ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.pvtserverebs.id
  instance_id = aws_instance.pvtserver.id
}