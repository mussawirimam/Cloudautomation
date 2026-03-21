### avoid using this, see the warining in for ingress/egress (aws_vpc_security_group_ingress_rule) : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#argument-reference
### use this instead for ingress to allow ssh on port 22: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_security_group" "securitygroup_allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  tags = {
    Name = "securitygroup_allow_ssh_tag"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.securitygroup_allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0" ### to allow the gateway to access the public internet ### this parameter is not available in official documentation: ### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group#argument-reference instead we will use cidr_blocks which is avaialbe parameter/argument in official documentation. Check below:
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.securitygroup_allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
/*
resource "aws_vpc_security_group_egress_rule" "example" {
  security_group_id = aws_security_group.example.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}
*/
