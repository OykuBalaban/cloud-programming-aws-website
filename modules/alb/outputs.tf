output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "target_group_arn" {
  value = aws_lb_target_group.web.arn
}

output "alb_arn_suffix" {
  value = aws_lb.web.arn_suffix
}

output "tg_arn_suffix" {
  value = aws_lb_target_group.web.arn_suffix
}
