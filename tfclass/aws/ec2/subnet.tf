### https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "mysubnet" {
    vpc_id            = aws_vpc.myvpc.id
    cidr_block        = "10.0.1.0/24"
#    availability_zone = "us-east-1a"
    tags = {
        Name = "mysubnet_tag"
    }
}
