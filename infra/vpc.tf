module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.10.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"]
  public_subnets  = ["10.10.4.0/24", "10.10.5.0/24", "10.10.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true
  enable_dns_support = true
  enable_vpn_gateway = false
  private_subnet_tags = {
    "karpenter.sh/discovery" =  "my-cluster-private"
  }
  tags = {
    Terraform   = "true"
    Environment = "dev"
    # "karpenter.sh/discovery" =  "my-cluster" # cluster name
  }
}