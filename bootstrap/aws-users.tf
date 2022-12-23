### USERS ###
resource "aws_identitystore_user" "batlogg_jodok" {
  # only create once, when running on -production
  count = local.environment == "production" ? 1 : 0

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = "Jodok Batlogg"
  user_name    = "jodok"
  name {
    given_name  = "Jodok"
    family_name = "Batlogg"
  }
  emails {
    value = "jodok@batlogg.com"
  }
}
resource "aws_identitystore_group_membership" "batlogg_jodok" {
  # only create once, when running on -production
  count = local.environment == "production" ? 1 : 0

  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.instance.group_id
  member_id         = aws_identitystore_user.example.user_id
}
