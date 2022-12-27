# Infrastructure workspace

You don't have to do anything to create the infrastructure workspaces. They are
bootstrapped by the bootstrap workspace.

## AWS Regions

Common infrastructure is deployed in eu-west-1, this is a good region for both,
us and europe.

The first instance is deployed in eu-central-2, as we're considering to set the
headquarters in Switzerland.

### IP Spaces for EKS

- eu-west-1: 10.0.0.0/16
- eu-central-2: 10.1.0.0/16
