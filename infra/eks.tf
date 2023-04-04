module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.24"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  #   control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    instance_type                          = "t2.micro"
    update_launch_template_default_version = true
    # iam_role_additional_policies = {
    #   AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    # }
  }
  eks_managed_node_groups = {
    green = {
      min_size     = 2
      max_size     = 3
      desired_size = 2

      instance_types  = ["t3a.small"]
      capacity_type   = "SPOT"
      node_group_name = "my-cluster-node-group"
    }
  }
  tags = {
    "karpenter.sh/discovery" = "my-cluster"
  }
}