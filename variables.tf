variable "aws_region" {
  default = "us-east-2"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR of the VPC"
  default     = "172.16.16.0/24"
}

variable "prefix" {
  type        = string
  description = "prefix to identify resources"
  default     = "my_demo"
}

variable "instance_type" {
  type        = string
  description = "machine instance type"
  default     = "t3.micro"
}

variable "aws_key" {
  type        = string
  description = "aws security PEM key"
}

variable "owner_tag" {
  type        = string
  description = "infrastructure owner"
}

variable "ttl_tag" {
  type        = number
  description = "infrastructure owner"
  default     = 72
}
