# Cloud Programming portfolio - Task 1

Terraform setup for a small website on AWS. CloudFront in front, an Application Load Balancer
in two availability zones and an Auto Scaling Group with EC2 instances behind it.
Alarms go out via SNS e-mail.

Modules:
- network: VPC, public/private subnets, internet gateway, S3 gateway endpoint
- alb: load balancer, target group, security group
- compute: launch template, auto scaling group, user_data.sh (installs nginx)
- cdn: CloudFront distribution, optional WAF
- monitoring: SNS topic + CloudWatch alarm

## Running it

You need Terraform 1.9+ and the AWS CLI configured (aws configure).

```
cp terraform.tfvars.example terraform.tfvars   # put your e-mail in there
terraform init
terraform plan
terraform apply
```

The website_url output is the CloudFront address. It takes a few minutes until it works.
Don't forget to confirm the SNS subscription mail.

To delete everything: terraform destroy
