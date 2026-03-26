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
### instead of using EOF to pass the user data to the instance that we are creating, we can also use the file function to read the content of a file and pass it as an input to the user_data argument of the aws_instance resource as shown below
/*  user_data = <<EOF
  #!/bin/bash
  apt update -y
  apt install httpd -y
  service httpd start
  chkconfig httpd 
  cd /var/www/html
  echo "<html><h1>Hello Cloud Gurus Welcome To My Webpage</h1></html>" > index.html
EOF
*/
user_data = file("myscript.sh") ## we are using the file function to read the content of the myscript.sh file and passing it as an input to the user_data argument of the aws_instance resource
depends_on = [local_file.private_key_file]  # ✅ wait for pem file first
  tags = {
    Name = "HelloWorld"
  }

### we are using the provisioner block to copy the nginx.conf file from our local machine to the instance that we created and we are renaming it to index.html and placing it in the /var/www/html directory of the instance
### you will need to add ssh connection block to the aws_instance resource to use the provisioner block and you will need to provide the private key that we created using the tls provider as an input in the ssh connection block
  provisioner "file" {
    source = "nginx.conf"
    destination = "/tmp/index.html"  # ✅ /tmp always exists
/*
The error is clear — file("my-aws-key.pem") can't be used here because the file is created by Terraform itself (via local_file resource) during the same apply, so it doesn't exist yet when Terraform evaluates the plan.
Fix — reference the key directly from the tls_private_key resource instead:
This way Terraform reads the private key from memory (the resource that created it) instead of trying to read it from a file that hasn't been written yet.
The rule is:

file() = reads from disk at plan time — file must already exist
resource.attribute = reads from Terraform state at apply time — always available
*/
connection {
  type        = "ssh"
  user        = "ubuntu"
  host        = self.public_ip
  private_key = tls_private_key.my-key-pair.private_key_pem  # ✅ read from resource directly
}
/*
  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = ""
    host     = aws_instance.web.public_ip
## we are providing the private key that we created using the tls provider as an input in the ssh connection block    
    private_key = file("my-aws-key.pem") 
  }
*/
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
  file_permission = "0400"  # ✅ sets correct permission automatically
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
