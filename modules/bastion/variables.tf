variable "name" {}

variable "bastion" {
  type        = "map"
  description = "Vars for bastion host."
}

variable "default_tags" {
  type        = "map"
  description = "Default tags to add to resources."
}
