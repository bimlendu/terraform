variable "name" {}
variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

variable "default_tags" {
  type = "map"
}

variable "source_security_groups" {}
