resource "aws_kms_key" "sops_eu-central-1" {
  provider    = aws.eu-central-1
  description = "Key for Mozilla SOPS"
}
resource "aws_kms_alias" "sops_eu-central-1" {
  provider      = aws.eu-central-1
  name          = "alias/sops"
  target_key_id = aws_kms_key.sops_eu-central-1.key_id
}

data "aws_kms_secrets" "sops_eu-central-1" {
  provider = aws.eu-central-1
  secret {
    name    = "opensearch_master"
    payload = var.rds_instance_config["${local.environment}_eu-central-1"].encrypted_root_password
  }
  secret {
    name    = "rds_root"
    payload = var.rds_instance_config["${local.environment}_eu-central-1"].encrypted_root_password
  }
}
