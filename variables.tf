variable "project_name" {
  type    = string
  default = "iu-cloud-web"
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "alert_email" {
  description = "where CloudWatch alarms get sent"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 6
}

variable "enable_waf" {
  type    = bool
  default = false
}
