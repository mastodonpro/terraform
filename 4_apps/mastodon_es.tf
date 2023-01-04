/*
disable as long mastodon doesn't support TLS connections
https://github.com/mastodon/mastodon/issues/19824

data "aws_elasticache_user" "default" {
  user_id = "default"
}
resource "aws_elasticache_user" "mastodon" {
  provider      = aws.eu-central-1
  user_id       = "mastodon"
  user_name     = "mastodon"
  access_string = "on ~mastodon::* +@all"
  engine        = "REDIS"
  passwords     = [data.aws_kms_secrets.eu-central-1.plaintext["redis_mastodon"]]
}
resource "aws_elasticache_user_group" "mastodon" {
  provider      = aws.eu-central-1
  engine        = "REDIS"
  user_group_id = "mastodon"
  user_ids      = [data.aws_elasticache_user.default.user_id, aws_elasticache_user.mastodon.user_id]
  lifecycle {
    ignore_changes = [user_ids]
  }
}
*/
