output "aws_account_id" {
  description = "The AWS account IDs"
  value = {
    staging    = aws_organizations_account.staging.id
    production = aws_organizations_account.production.id
  }
}
