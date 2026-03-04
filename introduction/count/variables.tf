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

### variables ### we will pas this in main.tf as var.filename_list
variable "filename_list" {
  type        = list
  description = "Name of the file to create"
  ### we will add a default as the list
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
