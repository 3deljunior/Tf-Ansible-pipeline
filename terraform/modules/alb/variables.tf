variable "project_name" {
  type    = string
  default = "dahab-web"
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "instance_ids" {
  type = list(string)
}
variable "instance_count" {
  type    = number
}