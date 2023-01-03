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

resource "aws_elasticache_cluster" "redis_eu-central-1" {
  provider             = aws.eu-central-1
  cluster_id           = "redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  engine_version       = "7.0"
  security_group_ids = [
    aws_default_security_group.eu-central-1.id,
    aws_security_group.redis_eu-central-1.id,
  ]
  subnet_group_name = aws_elasticache_subnet_group.redis_eu-central-1.name
}
