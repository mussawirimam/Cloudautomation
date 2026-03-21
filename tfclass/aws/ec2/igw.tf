### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "my_igw_tag"
  }
}
