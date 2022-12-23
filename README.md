# Mastodon pro Terraform infrastructure

The Mastodon pro infrastructure is being provisioned by
[Terraform Cloud](https://app.terraform.io/app/mastodonpro/workspaces/terraform).

Terraform Cloud is connected to this GitHub repository and triggering
speculative runs on PRs - and automatically applies changes on pushes
to main. You can read more about how the system is set up in the
[Hashicorp documentation](https://learn.hashicorp.com/tutorials/terraform/github-actions).

Before running terraform locally you need to run `terraform init` and
`terraform login`.

## Checks

A Github action will check the correct formatting of `.tf` files.
You can format your local files by running `terraform fmt`.

## Terraform Cloud, subdirectories and using Workspaces

Each subdirectory holds part of the infrastructure, the configuration is
identically for staging and production, but before running `terraform plan`
you need to choose the workspace you want to use::

```bash
terraform workspace select staging
```

When importing an existing resource you need to manually export the name of the
workspace, because the import is run locally and not on the remote backend:

```bash
TF_VAR_ATLAS_WORKSPACE_NAME=infrastructure-staging \
terraform import aws_route53_zone.zone ABCD1234
```

## Workspaces overview

There are three main workspaces:

- `bootstrap`, which bootstraps all the other workspaces.
- `infrastructure`, which contains all the base infrastructure that has to be
  set up. (separated for `staging` and `production`)
- `apps`, which contains all the application specific infrastructure that has
  to be set up. (separated for `staging` and `production`)
- `common`, which contains all the base infrastructure that is shared between
  `staging` and `production`.

So the base structure of the workspaces is:

```
└── bootstrap
    ├── common
    ├── infrastructure-staging
    ├── infrastructure-production
    ├── apps-staging
    └── apps-production
```

## Booting from scratch

See more in the [README](bootstrap/README.md) of the `bootstrap` module.
