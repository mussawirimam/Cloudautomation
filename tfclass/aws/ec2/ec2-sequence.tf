cat <<'eod' > ec2.tf 
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#argument-reference
#https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key#public_key_pem-1
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance

## CREATION ORDER:
## 1. tls_private_key     → generates RSA key pair
## 2. aws_key_pair        → uploads public key to AWS
## 3. local_file          → saves private key to disk (my-aws-key.pem)
## 4. aws_instance        → creates EC2 (depends_on local_file)
## 5. provisioner "file"  → SSHs in and copies nginx.conf to /tmp/index.html
## 6. myscript.sh         → moves /tmp/index.html to /var/www/html/index.html
## 7. local_file          → saves public IP to public_ip.txt
## 8. output              → prints public IP to terminal

resource "aws_instance" "web" {                                               ## 4 - created after key pair and pem file exist
  ami                         = "ami-0b6c6ebed2801a5cb"
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.my_aws_key.key_name              ## 4a - gets key name from aws_key_pair (step 2)
  vpc_security_group_ids      = [aws_security_group.securitygroup_allow_ssh.id]
  subnet_id                   = aws_subnet.mysubnet.id
  associate_public_ip_address = true
  user_data                   = file("myscript.sh")                           ## 4b - runs script on boot (step 6 happens inside instance)
  depends_on                  = [local_file.private_key_file]                 ## 4c - waits for pem file (step 3) before creating

  tags = {
    Name = "HelloWorld"
  }

    connection {                                                              ## 5a - SSH connection used by provisioner
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = tls_private_key.my-key-pair.private_key_pem              ## 5b - gets private key from tls_private_key (step 1)
#     private_key = file("my-aws-key.pem")                                           ## 5b alternative - gets private key from local file (step 3)      
    }

  provisioner "file" {                                                        ## 5 - after EC2 is up, copies nginx.conf from local machine → /tmp/index.html
    source      = "nginx.conf"
    destination = "/tmp/index.html"
  }
}

resource "tls_private_key" "my-key-pair" {                                    ## 1 - first: generates public + private RSA key
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_aws_key" {                                        ## 2 - uploads public key to AWS
  key_name   = "terraform_class_key"
  public_key = tls_private_key.my-key-pair.public_key_openssh                ## 2a - gets public key from tls_private_key (step 1)
}

resource "local_file" "private_key_file" {                                    ## 3 - saves private key to disk as my-aws-key.pem
  content         = tls_private_key.my-key-pair.private_key_pem              ## 3a - gets private key from tls_private_key (step 1)
  filename        = "my-aws-key.pem"
  file_permission = "0400"
}

resource "local_file" "public_ip_file" {                                      ## 7 - after EC2 is created, saves public IP to file
  content  = aws_instance.web.public_ip
  filename = "public_ip.txt"
}

output "public_ip" {                                                          ## 8 - prints public IP to terminal after apply
  value = aws_instance.web.public_ip
}

/*
The full dependency chain visualized:
```
1. tls_private_key
   ├── 2. aws_key_pair (needs public key)
   ├── 3. local_file/pem (needs private key)
   │    └── 4. aws_instance (depends_on pem)
   │         ├── 5. provisioner file (needs EC2 up + private key from step 1)
   │         └── 7. local_file/public_ip (needs EC2 public IP)
   └── 8. output (needs EC2 public IP)
*/
eod

