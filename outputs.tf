output "website_url" {
  value = "https://${module.cdn.cloudfront_domain_name}"
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "asg_name" {
  value = module.compute.asg_name
}
