variable "region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance sizing (minimum t3.medium for kubeadm)"
  type        = string
  default     = "t3.medium"
}

variable "environment" {
  description = "Deployment environment (dev / prod)"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "Admin IP address allowed SSH and K8s API (6443) access"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to local SSH public key"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}
