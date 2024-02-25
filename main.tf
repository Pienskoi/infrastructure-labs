terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  cloud {
    organization = "pienskoi-koroliuk"

    workspaces {
      name = "Lab2"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_key_pair" "kpi-lab2" {
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqBKuNDUCxY35pJgagcsg0zg3MaJofXMkdmIq4yJ+ERcAy65Dh3nOlOM35zrjZBJ+3tpQRM3P3vhylH8cC1krCNq16eT2c7TezfCTl/Bt2q2rPl0xsZlDYsYuAvn1OhI2rGrzn2Bk++El3LQB7uudVP6UBh9nXBWc2Vz5Cf11WzIo7qikWm0hW19HwTq6gJc0P4WtPs2hbBdQQLpvTZjtpaUNZFhhY9WJZdjD/xOaK95c1eykJRMloxpfHHY4KXSFxF3p+8CThWLf3KcQ9ijTQXuTi1s+D056ya0CP4ZKj6LzjvD7Eo0RFbd9o6R40lTXZ+LUR2NIg9PKY7F1h6EMd"
}

resource "aws_security_group" "kpi-labs-sg" {
  name = "kpi-labs-security-group"

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
}

resource "aws_instance" "kpi-lab2-server" {
  ami           = "ami-0faab6bdbac9486fb"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.kpi-lab2.key_name}"
  security_groups = [aws_security_group.kpi-labs-sg.name]
  user_data     = <<-EOF
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

    sudo docker run -p 80:80 --restart always --name lab2 pienskoi/webapp:latest
    sudo docker run -d --restart always --name watchtower -v /var/run/docker.sock:/var/run/docker.sock -e WATCHTOWER_POLL_INTERVAL=60 containrrr/watchtower

    EOF

  tags = {
    Project = "KPI infrastructure labs"
  }

}

output "ec2-public-url" {
  value = "${aws_instance.kpi-lab2-server.public_dns}"
}
