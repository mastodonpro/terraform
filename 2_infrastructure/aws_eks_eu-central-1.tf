# EKS and network resources. Parts taken from
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
# and https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf

# Helper data
data "aws_availability_zones" "eu-central-1" {
  provider = aws.eu-central-1
}
locals {
  vpc_cidr_eu-central-1 = "10.2.0.0/16"
  azs_eu-central-1      = slice(data.aws_availability_zones.eu-central-1.names, 0, 3)
}

module "eks_eu-central-1" {
  providers = {
    aws        = aws.eu-central-1
    kubernetes = kubernetes.aws_eu-central-1
  }
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = local.environment
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
      # add irsa annotation for role to cluster_addons
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ebs-csi-controller-sa"
    }
  }

  vpc_id                   = module.vpc_eks_eu-central-1.vpc_id
  subnet_ids               = module.vpc_eks_eu-central-1.private_subnets
  control_plane_subnet_ids = module.vpc_eks_eu-central-1.intra_subnets

  manage_aws_auth_configmap = true
  aws_auth_accounts = [
    data.aws_caller_identity.current.account_id
  ]
  aws_auth_roles = [
    {
      rolearn  = local.admin_sso_role_arn
      username = "aws-sso-admin"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_group_defaults = {
    ami_type       = "BOTTLEROCKET_x86_64"
    platform       = "bottlerocket"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
    #iam_role_additional_policies = {
    #  AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #}
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false
    }
  }
}

# Supporting resources
module "vpc_eks_eu-central-1" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"
  providers = {
    aws = aws.eu-central-1
  }

  name = "eks"
  cidr = local.vpc_cidr_eu-central-1

  azs             = local.azs_eu-central-1
  private_subnets = [for k, v in local.azs_eu-central-1 : cidrsubnet(local.vpc_cidr_eu-central-1, 4, k)]
  public_subnets  = [for k, v in local.azs_eu-central-1 : cidrsubnet(local.vpc_cidr_eu-central-1, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs_eu-central-1 : cidrsubnet(local.vpc_cidr_eu-central-1, 8, k + 52)]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  enable_flow_log                      = true
  create_flow_log_cloudwatch_iam_role  = true
  create_flow_log_cloudwatch_log_group = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

# Addons
module "ebs_csi_irsa_role_eu-central-1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.2"
  providers = {
    aws = aws.eu-central-1
  }
  role_name = "ebs-csi-controller-sa"
  role_policy_arns = {
    "ebs_csi" = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }
  # attach_ebs_csi_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks_eu-central-1.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}
module "external_dns_irsa_role_eu-central-1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.2"
  providers = {
    aws = aws.eu-central-1
  }
  role_name                  = "external-dns"
  attach_external_dns_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks_eu-central-1.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }
}
module "load_balancer_controller_irsa_role_eu-central-1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.2"
  providers = {
    aws = aws.eu-central-1
  }
  role_name                              = "aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = module.eks_eu-central-1.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}
### AWS KMS ACCESS FOR KUBERNETES ###
# https://fluxcd.io/docs/guides/mozilla-sops/
# This is required by flux to be able to decrypt SOPS secrets
resource "aws_iam_policy" "kms_sops_eu-central-1" {
  name        = "AmazonEKS_KMS_SOPS_Policy_eu-central-1"
  description = "AWS KMS Policy for SOPS - required by eks/flux"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_kms_key.sops_eu-central-1.arn}"
      }
    ]
  })
}

module "kustomize_controller_irsa_role_eu-central-1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.9.2"
  providers = {
    aws = aws.eu-central-1
  }
  role_name = "kustomize-controller"
  role_policy_arns = {
    "kms" = aws_iam_policy.kms_sops_eu-central-1.arn
  }
  oidc_providers = {
    ex = {
      provider_arn               = module.eks_eu-central-1.oidc_provider_arn
      namespace_service_accounts = ["flux-system:kustomize-controller"]
    }
  }
}
