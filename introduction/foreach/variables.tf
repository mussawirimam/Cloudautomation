variable "filename" {
  #default = "myfile.txt"
  type        = string
  description = "Name of the file to create"
  # validation block
  validation {
    condition     = substr(var.filename, 0, 4) == "dev-"
    error_message = "The value must be starting with dev-"
  }
}

### we are using this main main.tf as set for foreach 
### variables ### we will pas this in main.tf as var.filename_list
variable "filename_list" {
  type        = set(string)
  description = "Name of the file to create"
  ### we will add a default as the set
  default = [
    "myfirstfile.txt",
    "mysecondfile.txt",
    "mythirdfile.txt",
    "myfourthfile.txt",
    "myfifthfile.txt"
  ]
}

variable "file_content" {
  default = "This is the first file created using terraform"
  type = string
  # for datatypes, we can use: string, number, bool, list(), map()
  description = "The content of the file"
}
