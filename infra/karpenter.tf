
#######################################################################################################################################
# karpenter NODE role
resource "aws_iam_role" "karpenter-node-role" {
  name = "karpenter-node-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# attaching policies to ARN
resource "aws_iam_role_policy_attachment" "karpenter-policy-attachment" {
  for_each   = local.policy_arns
  role       = aws_iam_role.karpenter-node-role.name
  policy_arn = each.value
}

# creating the instance profile with role ARN
resource "aws_iam_instance_profile" "test_profile" {
  name = "KarpenterNodeInstanceProfile-my-cluster"
  role = aws_iam_role.karpenter-node-role.name
}

#######################################################################################################################################
# karpenter controller role
resource "aws_iam_role" "karpenter-controller-role" {
  name = "karpenter-controller-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:karpenter:karpenter"
          }
        }
      },
    ]
  })
}
# karpenter controller policy
resource "aws_iam_policy" "karpenter-controller-policy" {
  name        = "karpenter-controller-policy"
  path        = "/"
  description = "Karpenter controller policy"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:GetParameter",
          "ec2:DescribeImages",
          "ec2:RunInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstanceTypeOfferings",
          "ec2:DescribeAvailabilityZones",
          "ec2:DeleteLaunchTemplate",
          "ec2:CreateTags",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateFleet",
          "ec2:DescribeSpotPriceHistory",
          "pricing:GetProducts"
        ]
        Effect   = "Allow"
        Resource = "*"
        Sid      = "Karpenter"
      },
      {
        Action = "ec2:TerminateInstances"
        Condition = {
          StringLike = {
            "ec2:ResourceTag/Name" = "*karpenter*"
            # "ec2.ResourceTag/aws:eks:cluster-name" = "my-cluster"
          }
        }
        Effect   = "Allow"
        Resource = "*"
        Sid      = "ConditionalEC2Termination"
      },
      {
        Action   = "iam:PassRole"
        Effect   = "Allow"
        Resource = aws_iam_role.karpenter-node-role.arn
        Sid      = "PassNodeIAMRole"
      },
      {
        Action   = "eks:DescribeCluster"
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
        Sid      = "EKSClusterEndpointLookup"
      }
    ]
  })
}

# karpenter role-policy attachment
resource "aws_iam_role_policy_attachment" "karpenter-controller-policy-attachment" {
  role       = aws_iam_role.karpenter-controller-role.name
  policy_arn = aws_iam_policy.karpenter-controller-policy.arn
}