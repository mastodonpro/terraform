#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Run everything in a tmp folder to avoid race conditioning between the downloads
tmp_d=$(mktemp -d)
cp .sops.yaml ${tmp_d}
cd ${tmp_d}

tmp="${tmp_d}/unencrypted.yaml"

# Download SOPS binary
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  ARCH="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  ARCH="darwin"
fi
test -e sops || curl -Lo sops https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.${ARCH}
chmod 0755 sops

# Extract "unencrypted" argument from the input into file and add KMS ARN to .sops.yaml
eval "$(jq -r '@sh "echo \(.unencrypted) > ${tmp} && echo \"  kms: \(.kms_arn)\" >> ${tmp_d}/.sops.yaml"')"
cat ${tmp_d}/.sops.yaml
# Run SOPS and return encrypted file
# The output of SOPS changes each run, so also provide the sha256sum
jq -n \
  --arg encrypted "$(./sops --encrypt ${tmp})"\
  --arg sha256sum "$(sha256sum ${tmp})"\
  '{"encrypted":$encrypted, "sha256sum":$sha256sum}'

cd
rm -rf ${tmp_d}
