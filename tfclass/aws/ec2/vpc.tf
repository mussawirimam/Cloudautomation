### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default" 
  enable_dns_support   = true # we added this from the argument/parameter list 
  enable_dns_hostnames = true # we added this from the argument/parameter list 
  
  tags = {
    Name = "myvpc_tag"
  }
}
