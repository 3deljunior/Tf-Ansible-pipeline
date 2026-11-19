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

variable "instance_count" {
  type    = number
  default = 3
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing AWS EC2 Key Pair name (e.g., pops)"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0" # In production, restrict this to YOUR_IP/32
}