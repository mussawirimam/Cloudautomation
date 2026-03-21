#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#argument-reference
#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#public_key_pem-1
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance ### getting associate_public_ip from the data source of aws_instance
resource "aws_instance" "web" {
  ami           = "ami-0b6c6ebed2801a5cb" # you can find this in the documentation of aws_instance resource, or you can search for it in the AWS console
  instance_type = "t3.micro"
  ## 3 we are getting the key name as input from the aws_key_pair resource that we created below
  key_name = aws_key_pair.my_aws_key.key_name   ## 3 we are getting the key name as input from the aws_key_pair resource that we created below
  vpc_security_group_ids = [aws_security_group.securitygroup_allow_ssh.id] ## we are getting the security group id as input from the aws_security_group resource that we created below
  subnet_id = aws_subnet.mysubnet.id
  associate_public_ip_address = true ## we are associating public IP to the instance that we are creating
  tags = {
    Name = "HelloWorld"
  }
}
## 1st creatomg they key pair using the tls provider and then we are sending the public key to the aws_key_pair resource as an input and then we are getting the key name from the aws_key_pair resource as an input in the aws_instance resource
resource "tls_private_key" "my-key-pair" { ## 1 creates both public and private key and sends the public key to the aws_key_pair as an input (tls_private_key.web-private-key.public_key_openssh)
  algorithm = "RSA"
  rsa_bits  = 4096
}

## 2nd creating the key pair in AWS using the aws_key_pair resource and sending the public key from the tls_private_key resource as an input
resource "aws_key_pair" "my_aws_key" { 
  key_name   = "terraform_class_key"
  public_key = tls_private_key.my-key-pair.public_key_openssh ## 2 public key is being added from the tls_private_key as the input
}

## 4th we are outputting the private key that we created using the tls provider using local_file resource
resource "local_file" "private_key_file" {
  content  = tls_private_key.my-key-pair.private_key_pem
  filename = "my-aws-key.pem"
}

## 5th we are outputting the public IP of the instance that we created using the aws_instance resource using local_file resource
resource "local_file" "public_ip_file" {
  content  = aws_instance.web.public_ip
  filename = "public_ip.txt"
}
## you can also output the public IP using the output block as shown below
output "public_ip" {
  value = aws_instance.web.public_ip
}
