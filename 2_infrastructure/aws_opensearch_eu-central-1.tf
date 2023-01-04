resource "aws_security_group" "opensearch_eu-central-1" {
  provider = aws.eu-central-1
  name     = "opensearch"
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [module.vpc_eks_eu-central-1.vpc_cidr_block]
  }
  tags = { Name = "opensearch" }
}
resource "aws_iam_service_linked_role" "opensearch" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "opensearch_eu-central-1" {
  provider       = aws.eu-central-1
  domain_name    = "opensearch"
  engine_version = "OpenSearch_2.3"

  cluster_config {
    instance_type          = "t3.small.search"
    instance_count         = 1
    zone_awareness_enabled = false
  }

  advanced_security_options {
    enabled                        = false
    anonymous_auth_enabled         = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = "admin"
      master_user_password = data.aws_kms_secrets.sops_eu-central-1.plaintext["opensearch_master"]
    }
  }
  node_to_node_encryption {
    enabled = true
  }
  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
    volume_type = "gp2"
  }

  vpc_options {
    subnet_ids = [
      aws_default_subnet.eu-central-1a.id,
      # as long zone_awareness_enabled is false, we can only use one subnet
      # aws_default_subnet.eu-central-1b.id,
      # aws_default_subnet.eu-central-1c.id,
    ]
    security_group_ids = [aws_default_security_group.eu-central-1.id, aws_security_group.opensearch_eu-central-1.id]
  }
  depends_on = [aws_iam_service_linked_role.opensearch]
}
