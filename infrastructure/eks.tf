# EKS and network resources. Parts taken from
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/complete/main.tf
# and https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_managed_node_group/main.tf

# Helper data
data "aws_availability_zones" "available" {}
locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.environment
  cluster_version = "1.24"

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
  }

  vpc_id                   = module.vpc_eks.vpc_id
  subnet_ids               = module.vpc_eks.private_subnets
  control_plane_subnet_ids = module.vpc_eks.intra_subnets

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

    # Default node group - as provided by AWS EKS using Bottlerocket
    bottlerocket_default = {
      # By default, the module creates a launch template to ensure tags are propagated to instances, etc.,
      # so we need to disable it to use the default template provided by the AWS EKS managed node group service
      use_custom_launch_template = false

      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"
    }

    # Adds to the AWS provided user data
    bottlerocket_add = {
      ami_type = "BOTTLEROCKET_x86_64"
      platform = "bottlerocket"

      # This will get added to what AWS provides
      bootstrap_extra_args = <<-EOT
        # extra args added
        [settings.kernel]
        lockdown = "integrity"
      EOT
    }
  }
}

# Supporting resources
module "vpc_eks" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "eks"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

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
