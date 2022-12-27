# EKS and network resources. Parts taken from
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
# and https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf

# Helper data
data "aws_availability_zones" "eu-central-1" {
  provider = aws.eu-central-1
}
locals {
  vpc_cidr_eu-central-1 = "10.1.0.0/16"
  azs_eu-central-1      = slice(data.aws_availability_zones.eu-central-1.names, 0, 3)
}

module "eks_eu-central-1" {
  providers = {
    aws        = aws.eu-central-1
    kubernetes = kubernetes.aws_eu-central-1
  }
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name                   = "${local.environment}_eu-central-1"
  cluster_version                = "1.24"
  cluster_endpoint_public_access = true

  # IPV6
  cluster_ip_family = "ipv6"

  # We are using the IRSA created below for permissions
  # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
  # and then turn this off after the cluster/node group is created. Without this initial policy,
  # the VPC CNI fails to assign IPs and nodes cannot join the cluster
  # See https://github.com/aws/containers-roadmap/issues/1666 for more context
  # TODO - remove this policy once AWS releases a managed version similar to AmazonEKS_CNI_Policy (IPv4)
  create_cni_ipv6_iam_policy = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa_eu-central-1.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                   = module.vpc_eks_eu-central-1.vpc_id
  subnet_ids               = module.vpc_eks_eu-central-1.private_subnets
  control_plane_subnet_ids = module.vpc_eks_eu-central-1.intra_subnets

  manage_aws_auth_configmap = true

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {
    # Default node group - as provided by AWS EKS
    default_node_group = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false
    }

    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
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

  name = "eks_eu-central-1"
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

module "vpc_cni_irsa_eu-central-1" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  providers = {
    aws = aws.eu-central-1
  }

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv6   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks_eu-central-1.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
