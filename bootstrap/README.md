# Bootstrap workspace

This workspace is used to bootstrap the Terraform cloud environment. It's the
first and only one to be created manually.

## AWS

Running this workspace will create two independent sub-organizations to the
root account (subscriptions) - one for staging and another one for production.

To get this started you need to set up a few objects in your ROOT AWS account:

- create both an IAM user and group `terraform` and provide them with
  global administrator access (note the ACCESS_KEY data for later).

- enable IAM Center (make sure to select eu-west-1 region).

## Terraform Cloud (TFC)

On Terraform Cloud you need to create the workspace `bootstrap`.

The workspace need to be populated with the following environment variables:

- `AWS_ACCESS_KEY_ID` (AWS Access Key ID) and `AWS_SECRET_ACCESS_KEY`
  (AWS Secret Access Key) that belong to the top level AWS root account.
- This top-level "superuser" Access key will only be used to create the
  two environments. These environments operate on their own keys.
- Create a Terraform Organization Token - it will allow the TFE provider
  to create subsequent Terraform Cloud environments.
  (<https://app.terraform.io/app/mastodonpro/settings/authentication-tokens>)
  Set this token as sensitive `TFE_TOKEN`, `The Terraform cloud organization
  token`. It makes sense to add this to the variable set above as well.
- You need to create an GitHub App and connect it via an
  [OAuth App](https://www.terraform.io/docs/cloud/vcs/github.html) to the
  Terraform Cloud workspace. Note the resulting OAuth Token ID and set the
  `TFC_OAUTH_TOKEN_ID` variable correspondingly. (optional)

## Other hints

### Importing existing resources

`terraform import` runs partially on your local machine. It might be necessary
to set several environment variables (`TFE_TOKEN`, `AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`) and others::

```bash
#!/bin/bash
export TFE_TOKEN=""
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
```

For example the `bootstrap` workspace (a.k.a chicken-egg problem) can be
imported via:

```bash
TF_VAR_ATLAS_WORKSPACE_NAME=bootstrap terraform import tfe_organization.mastodonpro mastodonpro
```

### Nameserver settings

Make sure the nameservers of the domains `mastodonpro.com` and `mastodon-st.com`
are configured correctly. The registrar is iwantmyname. Use the output variables
to set them accordingly.
