### this file will run third as it will be get values from variables.tf file and create resources with it
### resource aws_iam_user
resource "aws_iam_user" "dev_users" {
  for_each = var.usernames
  name     = each.value

  tags = {
    class = "cloud automation"
  }
}

### resource aws_iam_user_policy
resource "aws_iam_user_policy" "dev_users_policy" {
  name = "dev_users_policy"
  for_each = aws_iam_user.dev_users              # ← add this
  
  user = each.value.name  # ← correct reference

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Statement1",
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:AssignIpv6Addresses",
        "ec2:AllocateAddress",
        "ec2:AcceptTransitGatewayVpcAttachment"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
