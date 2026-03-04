### resource
resource "local_file" "myfirstfile1" {
  filename = each.value ### it will look into each and everyname from the set of strings defined in the variable.tf using for_each meta-argument from line below
  for_each = var.filename_list ### 
  content = "hello guys welcome to my file"
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
