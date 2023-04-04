#!/bin/bash

# It is expected that you have executed the terraform commands to install the EKS cluster
# Installing karpenter
export KARPENTER_VERSION=v0.27.1

# change the node group in karpenter.yaml

kubectl create namespace karpenter
kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/v0.27.1/pkg/apis/crds/karpenter.sh_provisioners.yaml
kubectl create -f \
    https://raw.githubusercontent.com/aws/karpenter/v0.27.1/pkg/apis/crds/karpenter.k8s.aws_awsnodetemplates.yaml
kubectl apply -f karpenter.yaml


# apply this patch in aws-auth configmap
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::526077812922:role/karpenter-node-role
      username: system:node:{{EC2PrivateDNSName}}