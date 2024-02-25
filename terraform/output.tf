output "ec2-public-dns" {
  value = aws_instance.kpi-lab2-server.public_dns
}
