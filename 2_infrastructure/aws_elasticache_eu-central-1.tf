resource "aws_elasticache_subnet_group" "redis_eu-central-1" {
  provider = aws.eu-central-1
  name     = "redis"
  subnet_ids = [
    aws_default_subnet.eu-central-1a.id,
    aws_default_subnet.eu-central-1b.id,
    aws_default_subnet.eu-central-1c.id,
  ]
}

resource "aws_security_group" "redis_eu-central-1" {
  provider = aws.eu-central-1
  name     = "redis"
  ingress {
    protocol    = "tcp"
    from_port   = 6379
    to_port     = 6379
    cidr_blocks = [module.vpc_eks_eu-central-1.vpc_cidr_block]
  }
  tags = { Name = "redis" }
}

# https://github.com/hashicorp/terraform-provider-aws/issues/22123#issuecomment-989652326
resource "aws_elasticache_replication_group" "redis_eu-central-1" {
  provider             = aws.eu-central-1
  replication_group_id = "redis"
  description          = "encrpytion enabled"
  node_type            = "cache.t4g.micro"
  engine               = "redis"
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  security_group_ids = [
    aws_default_security_group.eu-central-1.id,
    aws_security_group.redis_eu-central-1.id,
  ]
  subnet_group_name = aws_elasticache_subnet_group.redis_eu-central-1.name
}
resource "aws_elasticache_cluster" "redis_eu-central-1" {
  provider             = aws.eu-central-1
  replication_group_id = aws_elasticache_replication_group.redis_eu-central-1.id
  cluster_id           = "redis"
}
