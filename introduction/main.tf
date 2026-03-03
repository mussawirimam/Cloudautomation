### resource
resource "local_file" "myfirstfile1" {
  filename = var.filename_list[count.index] ### we are passing 3 list of files from the variables.tf file. There are three items not a single value
  content = "hello guys welcome to my file"
  count = length(var.filename_list) ###whatever the count is there in the variable, that is the count I want. Best Practice     
  #content  = var.file_content
  #content  = "my new file content ${random_pet.mypetname.id}"
}

resource "random_pet" "mypetname1" {
  length    = 1
  prefix    = "MR"
  separator = "."
}

resource "random_pet" "mypetname3" {
  length    = 2
  prefix    = "MR"
  separator = "."
  depends_on = [
    random_pet.mypetname1
  ]  
}

resource "random_pet" "mypetname2" {
  length    = 10
  prefix    = "MR"
  separator = "."
}
resource "random_pet" "mypetname4" {
  length    = 10
  prefix    = "MR"
  separator = "."
}
resource "random_pet" "mypetname5" {
  length    = 10
  prefix    = "MR"
  separator = "."
}
/*
### output block
output "my_pet_name" {
  value = random_pet.mypetname.id
}
*/
