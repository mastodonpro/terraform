# Infrastructure workspace

You don't have to do anything to create the infrastructure workspaces. They are
bootstrapped by the bootstrap workspace.

## AWS Regions

Common infrastructure is deployed in eu-west-1, the latency of this region is
good for both, us and europe.

The first instance is deployed in eu-central-2, as we're considering to set the
headquarters in Switzerland. Note that you also need to enable that region in the
[AWS Management Console](https://us-east-1.console.aws.amazon.com/billing/home?region=us-east-1#/account?AWS-Regions).
Also change the validity of STS tokens added by the global endpoint to "All regions"
in the [AWS IAM console](https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/account_settings).

### IP Spaces for EKS

- eu-west-1: 10.0.0.0/16
- eu-central-2: 10.1.0.0/16
