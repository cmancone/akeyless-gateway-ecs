# Terraform Module to Launch an AKeyless Gateway in ECS

This terraform module will launch an ECS cluster, service, task, and load balancer to create an AKeyless gateway.  Note that AKeyless has great support for [running gateways on K8s](https://docs.akeyless.io/docs/deploy-the-api-gateway-on-kubernetes) via helm charts, so you may prefer that.  The only reason I can think of to use this module is if you're not already invested in K8s and/or don't want to pay per-cluster administrative fee from AWS (~$72/month/cluster) for a new cluster.

## Usage

```
module "akeyless_gateway" {
  source = "git::https://github.com/cmancone/akeyless-gateway-ecs.git"

  name = "my_gateway"
  region = "us-east-1"
  vpc_id = "vpc-123456789"
  public_subnet_ids = ["subnet-123456789", "subnet-987654321"]
  private_subnet_ids = ["subnet-abcdefgh", "subnet-hgfedcba"]
  route_53_hosted_zone_name = "subdomain.example.com"
  domain_name = "gateway.subdomain.example.com"
  iam_role_arn = "arn:aws:iam::account:role/role-name-with-path"
  admin_access_id = "p-123456789"
  allowed_access_ids = "p-987654321"
}
```

For the admin access id, your best bet will be to create a AWS IAM auth method in AKeyless that is associated with the IAM role ARN you attach to the gateway, and then use its access id as your `admin_access_id`.

## Inputs

| Name                               | Required | Type            | Default Value                                                    | Example                                                    | Notes |
|------------------------------------|----------|-----------------|------------------------------------------------------------------|------------------------------------------------------------|-------|
| name                               | Yes      | string          |                                                                  | `"my_gateway"`                                             | Also used as the name for the gateway in AKeyless |
| region                             | Yes      | string          |                                                                  | `"us-east-1"`                                              | The region to use |
| vpc_id                             | Yes      | string          |                                                                  | `"vpc-123456789"`                                          | The VPC to place the infrastructure in |
| public_subnet_ids                  | Yes      | list of strings |                                                                  | `["subnet-123456789", "subnet-abcdefgh"]`                  | The subnets to place the load balancer in |
| private_subnet_ids                 | Yes      | list of strings |                                                                  | `["subnet-123456789", "subnet-abcdefgh"]`                  | The subnets to place the ECS tasks in |
| gateway_ports                      | No       | map of integers | `{8000: 8000, 18888: 18888, 8200: 8200, 8080: 8080, 5696: 5696}` |                                                            | Port map for load balancer: extenal ports to internal ports (see [the docs](https://docs.akeyless.io/docs/install-and-configure-the-gateway)) |
| security_group_allowed_cidr_blocks | No       | list of strings | `["0.0.0.0/0"]`                                                  |                                                            | List of CIDR blocks that are allowed to access the load balancer |
| route_53_hosted_zone_name          | Yes      | string          |                                                                  | `"subdomain.example.com"`                                  | The name of the Route 53 hosted zone that will contain the domain for the gateway |
| domain_name                        | Yes      | string          |                                                                  | `"akeyless.subdomain.example.com"`                         | The domain to host the gateway on |
| iam_role_arn                       | Yes      | string          |                                                                  | `"arn:aws:iam::account:role/role-name-with-path"`          | The ARN of an IAM role to associate with the service |
| admin_access_id                    | Yes      | string          |                                                                  | `"p-12345689"`                                             | The access id of the auth method that the gateway should use (see [the docs](https://docs.akeyless.io/docs/install-and-configure-the-gateway)) |
| allowed_access_ids                 | Yes      | string          |                                                                  | `"p-12345689,p-987654321"`                                 | access ids used by admins to configure the gateway (see [the docs](https://docs.akeyless.io/docs/install-and-configure-the-gateway)) |
| desired_task_count                 | No       | integer         | `1`                                                              |                                                            | The number of tasks to use for the ECS service |
| alb_access_logs_bucket_name        | No       | string          |                                                                  | `"my_log_bucket"`                                          | The name of a bucket to send load balancer logs to |
| ssl_policy                         | No       | string          | `"ELBSecurityPolicy-TLS-1-2-2017-01"`                            |                                                            | The AWS SSL policy string to use with the load balancer (see [the docs](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#tls-security-policies)) |
| tags                               | No       | map of strings  |                                                                  | `{"service": "my_service", "environment": "production"}`   | Tags to attach to all applicable resources |

## Outputs

| Name                        | Value |
|-----------------------------|-------|
| lb_security_group_id        | The ID of the security group for the load balancer. |
| ecs_tasks_security_group_id | The ID of the security group for the ECS tasks. |
| ecs_cluster_arn             | The ARN of the ECS cluster. |
