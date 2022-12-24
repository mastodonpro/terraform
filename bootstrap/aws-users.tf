### USERS ###
resource "aws_identitystore_user" "batlogg_jodok" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = "Jodok Batlogg"
  user_name    = "jodok.batlogg"
  name {
    given_name  = "Jodok"
    family_name = "Batlogg"
  }
  emails {
    value = "jodok@batlogg.com"
  }
}
resource "aws_identitystore_user" "behmann_walter" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = "Walter Behmann"
  user_name    = "walter.behmann"
  name {
    given_name  = "Walter"
    family_name = "Behmann"
  }
  emails {
    value = "wbehmann@gmail.com"
  }
}
resource "aws_identitystore_user" "rochko_eugen" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = "Eugen Rochko"
  user_name    = "eugen.rochko"
  name {
    given_name  = "Eugen"
    family_name = "Rochko"
  }
  emails {
    value = "eugen@joinmastodon.org"
  }
}
resource "aws_identitystore_user" "roessl_bernd" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]

  display_name = "Bernd Roessl"
  user_name    = "bernd.roessl"
  name {
    given_name  = "Bernd"
    family_name = "Roessl"
  }
  emails {
    value = "bernd.roessl@gmail.com"
  }
}

### GROUP MEMBERSHIPS ###
resource "aws_identitystore_group_membership" "batlogg_jodok" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sysadmins.group_id
  member_id         = aws_identitystore_user.batlogg_jodok.user_id
}
resource "aws_identitystore_group_membership" "behmann_walter" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sysadmins.group_id
  member_id         = aws_identitystore_user.behmann_walter.user_id
}
resource "aws_identitystore_group_membership" "rochko_eugen" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sysadmins.group_id
  member_id         = aws_identitystore_user.rochko_eugen.user_id
}
resource "aws_identitystore_group_membership" "roessl_bernd" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.instance.identity_store_ids)[0]
  group_id          = aws_identitystore_group.sysadmins.group_id
  member_id         = aws_identitystore_user.roessl_bernd.user_id
}
