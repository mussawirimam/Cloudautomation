### route table should be attached to the vpc, and then we can attach it to the subnet as well. We can have multiple route tables, but for now we will just create one and attach it to the subnet.
### we will also use the route_table_association resource to associate the route table with the subnet.
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id ## we want to attach it to the internet gateway so we can route traffic to the internet
  }

  ### we removed ipv6 for now, but we can add it back later if we want to
  tags = {
    Name = "my_rt_tag"
  }
}

resource "aws_route_table_association" "rt_subnet_association" {
  subnet_id      = aws_subnet.mysubnet.id
  route_table_id = aws_route_table.my_rt.id
}
