### S3 bucket
resource "aws_s3_bucket" "s3_bucket_in_tf" {
  bucket = "terraform-class-visualpathz" ### you can see this in the mandatory parameters/argument reference

  tags = {
    Name        = "TerraformClass"
    Environment = "Dev"
    Cost_Center = "projectA"
  }
}
### Lifecycle policy 
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  bucket = aws_s3_bucket.s3_bucket_in_tf.id # .id happens to equal the bucket name = terraform-class-visualpath from above resource block
## when it comes to variables for rules, dont use it because it becomes the string. 
## use the locals keyword to create a local variable and then use that to call it in the rule. Locals is not making the it string but is making it a alias. 
#.eg
# locals {
#   log_rule = [
#     id = "first rule"
#     filter{
#       prefix = "dev/"
# expiration {
#         days = 30     
#    }
#   }
#  ]
#}
### to call the local variable in the rule, you can do this
# rule = local.log_rule

# rule is list of configurations and is a configuration block
  rule { 
    id = "my-lifecycle-rule" # this is a unique identifier for the rule

    filter{
      prefix = "dev/" # this is the prefix filter, you can specify a prefix to apply the lifecycle rule to objects with that prefix
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    # ... other transition/expiration actions ...
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration {
      days = 365
    }
    status = "Enabled"
  }
}
