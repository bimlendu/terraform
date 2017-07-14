variable "name" {}

variable "lc" {
  type        = "map"
  description = "Vars for bastion host."
}

variable "elb" {
  type        = "map"
  description = "Vars for bastion host."
}

variable "asg" {
  type        = "map"
  description = "Vars for bastion host."
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to add to resources."
}

variable "elb_subnets" {
  type = "list"
}

variable "asg_subnets" {
  type = "list"
}
