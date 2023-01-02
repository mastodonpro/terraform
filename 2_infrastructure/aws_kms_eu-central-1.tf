# staging
resource "aws_kms_key" "sops_eu-central-1" {
  provider    = aws.eu-central-1
  description = "Key for Mozilla SOPS"
}
resource "aws_kms_alias" "sops_eu-central-1" {
  provider      = aws.eu-central-1
  name          = "alias/sops_eu-central-1"
  target_key_id = aws_kms_key.sops_eu-central-1.key_id
}
