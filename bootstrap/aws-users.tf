### USERS ###
resource "aws_identitystore_user" "batlogg_jodok" {
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

### GROUPS ###
resource "aws_identitystore_group" "sysadmins" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.sysadmins.identity_store_ids)[0]
  display_name      = "Sysadmins"
  description       = "System Administrators"
}

### GROUP MEMBERSHIPS ###
resource "aws_identitystore_group_membership" "batlogg_jodok" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sysadmins.group_id
  member_id         = aws_identitystore_user.batlogg_jodok.user_id
}
