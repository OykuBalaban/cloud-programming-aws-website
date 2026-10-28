# Cloud Programming portfolio (DLBSEPCP01_E) - Host a simple webpage on AWS

This repo contains the Terraform code for the architecture from my concept phase,
"Global Edge, Multi-AZ Web Tier". It hosts a simple hello-world page on AWS in a way
that is highly available, fast for visitors worldwide and scales automatically.

## Architecture

```
visitors -> CloudFront (+ WAF) -> Application Load Balancer -> Auto Scaling Group (EC2 + nginx)
                                      public subnets               private subnets
                                      AZ a + AZ b                  AZ a + AZ b
```

- **CloudFront** caches the page at edge locations around the world and terminates HTTPS.
- **AWS WAF** (optional) sits in front of CloudFront with the AWS managed common rule set.
- **Application Load Balancer** in two Availability Zones, only reachable from CloudFront IPs.
- **Auto Scaling Group** with 2 to 6 EC2 instances (t3.micro, Amazon Linux 2023, nginx),
  spread over two AZs in private subnets without public IPs.
  Scales on requests per instance (target: 100).
- **S3 gateway endpoint** instead of a NAT Gateway so the instances can install nginx
  from the Amazon Linux repos. The endpoint is free, a NAT Gateway is billed per hour.
- **CloudWatch alarm + SNS** sends an e-mail when a server fails the health check.

Region is eu-north-1 (Stockholm). The concept said Frankfurt, but the AWS Free plan
locks a new account to one region and mine was assigned to Stockholm.

## Repo structure

```
main.tf                     wires the modules together
variables.tf                inputs (region, instance type, sizes, e-mail, WAF on/off)
outputs.tf                  website URL, ALB address, ASG name
providers.tf                AWS provider for eu-north-1 and a second one for us-east-1 (WAF)
versions.tf                 Terraform >= 1.9, AWS provider 6.x
terraform.tfvars.example    template for your own settings
modules/
  network/                  VPC, 2 public + 2 private subnets, internet gateway, S3 endpoint
  alb/                      load balancer, target group, listener, security group
  compute/                  launch template, auto scaling group, scaling policy, user_data.sh
  cdn/                      CloudFront distribution and optional WAF web ACL
  monitoring/               SNS topic, e-mail subscription, CloudWatch alarm
```

## Requirements

- Terraform 1.9 or newer (https://developer.hashicorp.com/terraform/install)
- AWS CLI (https://aws.amazon.com/cli/)
- An AWS account and an IAM user with enough rights to create VPC, EC2, ELB,
  CloudFront, WAF, CloudWatch and SNS resources. I used AdministratorAccess for the project.

Configure the CLI once:

```
aws configure
```

Enter the access key, secret key, region (eu-north-1) and output format (json).

## Deploy

1. Clone the repo and open a terminal in the folder.
2. Create your settings file:

   ```
   cp terraform.tfvars.example terraform.tfvars
   ```

   Put your e-mail in `alert_email`. Leave `enable_waf = false` for the first run.

3. Run Terraform:

   ```
   terraform init
   terraform validate
   terraform plan
   terraform apply
   ```

   Type `yes` when asked. The first apply takes about 5 to 10 minutes, CloudFront is the slow part.

4. AWS sends a "Subscription Confirmation" mail for the SNS topic. Click the link in it,
   otherwise no alarms arrive.

5. Open the `website_url` output in a browser. If you get a 502 or 504 in the first
   minutes, the instances are still installing nginx. Wait a bit and refresh.

## Variables

| name          | default        | what it does                                   |
|---------------|----------------|------------------------------------------------|
| project_name  | iu-cloud-web   | prefix for all resource names                  |
| aws_region    | eu-north-1     | region for VPC, ALB and EC2                    |
| alert_email   | (required)     | address for CloudWatch alarms                  |
| instance_type | t3.micro       | EC2 type for the web servers                   |
| min_size      | 2              | minimum instances, one per AZ                  |
| max_size      | 6              | upper limit for scaling out                    |
| enable_waf    | false          | attach AWS WAF with managed rules to CloudFront|

## Checking that it works

Headers show that the request went through CloudFront and was served by nginx:

```
curl -I https://<your-cloudfront-domain>
```

Look for `Server: nginx`, `Via: ... (CloudFront)` and `X-Cache`. The first call is a
`Miss`, the second one a `Hit`.

The ALB address (`terraform output alb_dns_name`) should not load in a browser.
Its security group only allows the CloudFront managed prefix list.

To test high availability, terminate one instance in the EC2 console. The site keeps
working from the other AZ and the Auto Scaling Group starts a replacement within a
few minutes. The CloudWatch alarm sends an e-mail while the target is unhealthy.

## Enabling WAF

Set `enable_waf = true` in `terraform.tfvars` and run `terraform apply` again.
This creates a web ACL in us-east-1 (required for CloudFront) and attaches it.

## Costs

The ALB, the EC2 instances and WAF are billed per hour. On the Free plan this comes
out of the signup credits. Remove everything when you are done:

```
terraform destroy
```

## Known limitations

- No custom domain, so the default `*.cloudfront.net` certificate is used and the
  connection from CloudFront to the ALB is plain HTTP.
- The IAM user has AdministratorAccess. A production setup should use a narrower policy.
- Terraform state is local. For teamwork an S3 backend with locking would be better.
- Only one region. A multi-region setup would improve availability further but costs more.
