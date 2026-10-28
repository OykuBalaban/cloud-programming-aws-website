module "network" {
  source       = "./modules/network"
  project_name = var.project_name
}

module "alb" {
  source            = "./modules/alb"
  project_name      = var.project_name
  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
}

module "compute" {
  source             = "./modules/compute"
  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.alb.alb_sg_id
  target_group_arn   = module.alb.target_group_arn
  alb_arn_suffix     = module.alb.alb_arn_suffix
  tg_arn_suffix      = module.alb.tg_arn_suffix
  instance_type      = var.instance_type
  min_size           = var.min_size
  max_size           = var.max_size
}

module "cdn" {
  source       = "./modules/cdn"
  project_name = var.project_name
  alb_dns_name = module.alb.alb_dns_name
  enable_waf   = var.enable_waf

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "monitoring" {
  source         = "./modules/monitoring"
  project_name   = var.project_name
  alert_email    = var.alert_email
  alb_arn_suffix = module.alb.alb_arn_suffix
  tg_arn_suffix  = module.alb.tg_arn_suffix
}
