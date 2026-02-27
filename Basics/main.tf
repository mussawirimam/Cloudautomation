### resource
resource "local_file" "myfirstfile1" {
  filename = var.filename
  #content  = var.file_content
  content  = "my new file content ${random_pet.mypetname.id}"
  lifecycle {
    create_before_destroy = true
  }
}
resource "random_pet" "mypetname" {
  length    = 2
  prefix    = "MR"
  separator = "."
}

### output block
output "my_pet_name" {
  value = random_pet.mypetname.id
}