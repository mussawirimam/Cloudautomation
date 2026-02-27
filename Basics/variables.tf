### variables
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

variable "file_content" {
  default = "This is the first file created using terraform"
  type = string
  # for datatypes, we can use: string, number, bool, list(), map()
  description = "The content of the file"
}