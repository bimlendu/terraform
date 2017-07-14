variable "name" {}
variable "vpc_id" {}

variable "subnets" {
  type = "list"
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to add to resources."
}
