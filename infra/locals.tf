locals {
  policy_arns = {
    policy1 = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    policy2 = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    policy3 = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    policy4 = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }
}