variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "my_ip" {
  description = "this ip use to access ssh port"
  type = string
}