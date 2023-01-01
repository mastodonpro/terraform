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
### AWS KMS ACCESS FOR KUBERNETES ###
# https://fluxcd.io/docs/guides/mozilla-sops/
# This is required by flux to be able to decrypt SOPS secrets
resource "aws_iam_policy" "kms_sops_eu-central-1" {
  provider    = aws.eu-central-1
  name        = "AWSKMSSopsIAMPolicy_eu-central-1"
  description = "AWS KMS Policy for SOPS - required by eks/flux"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Effect" : "Allow",
        "Resource" : "${aws_kms_key.sops_eu-central-1.arn}"
      }
    ]
  })
}
resource "tfe_variable_set" "sops" {
  name         = "SOPS"
  description  = "Mozilla SOPS variables."
  organization = data.tfe_organization.tfc.id
}
resource "tfe_variable" "sops_kms_arn_eu-central-1" {
  key             = "SOPS_KMS_ARN"
  description     = "KMS Key ARN for SOPS eu-central-1"
  value           = aws_kms_key.sops_eu-central-1.arn
  category        = "env"
  variable_set_id = tfe_variable_set.sops.id
}

# SOPS vars
resource "tfe_workspace_variable_set" "sops_apps" {
  variable_set_id = tfe_variable_set.sops.id
  workspace_id    = data.tfe_workspace.apps.id
}
