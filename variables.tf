variable "region" {
  description = "AWS region where resources will be provisioned"
  type        = string
}

variable "vpc_name" {
  description = "Name tag of the VPC where resources will be provisioned"
  type        = string
}

variable "image_ami" {
  description = "AMI ID for Ubuntu 22.04"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where EC2 instances will be launched"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
}

variable "subnets" {
  description = "List of subnet IDs for load balancer"
  type        = list(string)
}