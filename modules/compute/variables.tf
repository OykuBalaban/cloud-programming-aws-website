variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "tg_arn_suffix" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}
