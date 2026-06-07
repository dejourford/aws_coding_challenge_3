variable "region" {
  type = string
  default = "us-east-2"
}

variable "project_name" {
  type = string
  default = "aws-tech-challenge-3"
}

variable "environment" {
  type = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "key_name" {
  type = string
  default = "1PU"
}
