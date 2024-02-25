locals {
  project_name        = "KPI infrastructure labs"
  security_group_name = "kpi-labs-security-group"
  key_pair_name       = "kpi-lab2"
  instance_name       = "kpi-lab2-server"
  ubuntu_ami          = "ami-0faab6bdbac9486fb"
}

resource "aws_key_pair" "kpi-lab2" {
  key_name   = local.key_pair_name
  public_key = var.public_key_value

  tags = {
    Name    = local.key_pair_name,
    Project = local.project_name
  }
}

resource "aws_security_group" "kpi-labs-sg" {
  name = local.security_group_name

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = local.security_group_name,
    Project = local.project_name
  }
}

resource "aws_instance" "kpi-lab2-server" {
  ami             = local.ubuntu_ami
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.kpi-lab2.key_name
  security_groups = [aws_security_group.kpi-labs-sg.name]
  user_data       = file("./ec2/init.sh")
  tags = {
    Name    = local.instance_name,
    Project = local.project_name
  }

}
