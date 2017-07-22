variable "name" {}

variable "vpc_id" {}

variable "db" {
  type        = "map"
  description = "Vars for db."
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to add to resources."
}
