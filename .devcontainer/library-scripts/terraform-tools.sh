#!/usr/bin/env bash
set -e

# Clean up any leftover files from previous runs
rm -f /tmp/terraform.zip /tmp/packer.zip /tmp/terraform-docs.tar.gz /tmp/tfsec /tmp/terrascan.tar.gz /tmp/tflint.zip /tmp/tflint-aws-ruleset.zip /tmp/tflint-azure-ruleset.zip /tmp/tflint-gcp-ruleset.zip /tmp/terragrunt /tmp/infracost.tar.gz /tmp/go.tar.gz /tmp/terratest /tmp/terraform /tmp/packer /tmp/LICENSE.txt /tmp/terraform-docs /tmp/tflint /tmp/terrascan

# This script installs Terraform, Packer, and related tools

# Get architecture
ARCH=${TARGETARCH:-"amd64"}
if [ "$ARCH" = "arm64" ]; then
    ARCH="arm64"
    TERRASCAN_ARCH="arm64"
else
    ARCH="amd64"
    TERRASCAN_ARCH="x86_64"
fi

# Versions
TERRAFORM_VERSION=${1:-"1.12.1"}
TERRAFORM_DOCS_VERSION=${2:-"0.20.0"}
TFSEC_VERSION=${3:-"1.28.13"}
TERRASCAN_VERSION=${4:-"1.19.9"}
TFLINT_VERSION=${5:-"0.48.0"}
TFLINT_AWS_RULESET_VERSION=${6:-"0.23.1"}
TFLINT_AZURE_RULESET_VERSION=${7:-"0.23.0"}
TFLINT_GCP_RULESET_VERSION=${8:-"0.23.1"}
TERRAGRUNT_VERSION=${9:-"0.50.1"}
TERRATEST_VERSION=${10:-"0.49.0"}
INFRACOST_VERSION=${11:-"0.10.41"}
CHECKOV_VERSION=${12:-"3.2.439"}
PACKER_VERSION=${13:-"1.14.3"}

echo "Installing Terraform v${TERRAFORM_VERSION}..."
curl -sSL -o /tmp/terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip"
unzip -qq /tmp/terraform.zip -d /tmp
sudo mv /tmp/terraform /usr/local/bin/
rm -f /tmp/terraform.zip

echo "Installing Packer v${PACKER_VERSION}..."
# Packer is installed separately in Dockerfile
# curl -sSL -o /tmp/packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${ARCH}.zip"
# unzip -q -o /tmp/packer.zip -d /tmp
# sudo mv /tmp/packer /usr/local/bin/
# rm -f /tmp/packer.zip

echo "Installing terraform-docs v${TERRAFORM_DOCS_VERSION}..."
curl -sSLo /tmp/terraform-docs.tar.gz "https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-linux-${ARCH}.tar.gz"
tar -xzf /tmp/terraform-docs.tar.gz -C /tmp
sudo mv /tmp/terraform-docs /usr/local/bin/
rm -f /tmp/terraform-docs.tar.gz

echo "Installing tfsec v${TFSEC_VERSION}..."
curl -sSLo /tmp/tfsec "https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec-linux-${ARCH}"
sudo mv /tmp/tfsec /usr/local/bin/
sudo chmod +x /usr/local/bin/tfsec

echo "Installing terrascan v${TERRASCAN_VERSION}..."
curl -sSLo /tmp/terrascan.tar.gz "https://github.com/tenable/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_${TERRASCAN_ARCH}.tar.gz"
tar -xzf /tmp/terrascan.tar.gz -C /tmp
sudo mv /tmp/terrascan /usr/local/bin/
rm -f /tmp/terrascan.tar.gz

echo "Installing tflint v${TFLINT_VERSION}..."
curl -sSLo /tmp/tflint.zip "https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${ARCH}.zip"
unzip -o -qq /tmp/tflint.zip -d /tmp
sudo mv /tmp/tflint /usr/local/bin/
rm -f /tmp/tflint.zip

echo "Installing TFLint AWS ruleset v${TFLINT_AWS_RULESET_VERSION}..."
mkdir -p ~/.tflint.d/plugins
curl -sSLo /tmp/tflint-aws-ruleset.zip "https://github.com/terraform-linters/tflint-ruleset-aws/releases/download/v${TFLINT_AWS_RULESET_VERSION}/tflint-ruleset-aws_linux_${ARCH}.zip"
unzip -o -qq /tmp/tflint-aws-ruleset.zip -d ~/.tflint.d/plugins
rm -f /tmp/tflint-aws-ruleset.zip

echo "Installing TFLint Azure ruleset v${TFLINT_AZURE_RULESET_VERSION}..."
curl -sSLo /tmp/tflint-azure-ruleset.zip "https://github.com/terraform-linters/tflint-ruleset-azurerm/releases/download/v${TFLINT_AZURE_RULESET_VERSION}/tflint-ruleset-azurerm_linux_${ARCH}.zip"
unzip -o -qq /tmp/tflint-azure-ruleset.zip -d ~/.tflint.d/plugins
rm -f /tmp/tflint-azure-ruleset.zip

echo "Installing TFLint GCP ruleset v${TFLINT_GCP_RULESET_VERSION}..."
curl -sSLo /tmp/tflint-gcp-ruleset.zip "https://github.com/terraform-linters/tflint-ruleset-google/releases/download/v${TFLINT_GCP_RULESET_VERSION}/tflint-ruleset-google_linux_${ARCH}.zip"
unzip -o -qq /tmp/tflint-gcp-ruleset.zip -d ~/.tflint.d/plugins
rm -f /tmp/tflint-gcp-ruleset.zip

echo "Installing Terragrunt v${TERRAGRUNT_VERSION}..."
curl -sSLo /tmp/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${ARCH}"
sudo mv /tmp/terragrunt /usr/local/bin/
sudo chmod +x /usr/local/bin/terragrunt

echo "Installing Terratest v${TERRATEST_VERSION}..."
# Terratest is a Go library, so we'll set an environment variable to track the version
echo "export TERRATEST_VERSION=${TERRATEST_VERSION}" >> /home/vscode/.bashrc

# Install Go if not already installed
if ! command -v go &> /dev/null; then
  echo "Installing Go (required for Terratest)..."
  GO_VERSION="1.21.5"
  curl -sSLo /tmp/go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/vscode/.bashrc
  echo 'export PATH=$PATH:$HOME/go/bin' >> /home/vscode/.bashrc
  rm -f /tmp/go.tar.gz
fi

# Create a simple wrapper script for terratest
cat > /tmp/terratest << EOF
#!/bin/bash
echo "Terratest v${TERRATEST_VERSION}"
echo "Terratest is a Go library for testing infrastructure code."
echo "To use Terratest, add it to your Go project:"
echo "go get github.com/gruntwork-io/terratest@v${TERRATEST_VERSION}"
EOF
sudo mv /tmp/terratest /usr/local/bin/
sudo chmod +x /usr/local/bin/terratest

echo "Installing Infracost v${INFRACOST_VERSION}..."
curl -sSLo /tmp/infracost.tar.gz "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-${ARCH}.tar.gz"
tar -xzf /tmp/infracost.tar.gz -C /tmp
sudo mv /tmp/infracost-linux-${ARCH} /usr/local/bin/infracost
rm -f /tmp/infracost.tar.gz

echo "Installing Checkov v${CHECKOV_VERSION}..."
pip3 install --break-system-packages checkov==${CHECKOV_VERSION}

# Create .tflint.hcl config file
mkdir -p /home/vscode/.tflint.d
cat > /home/vscode/.tflint.hcl << EOF
plugin "aws" {
  enabled = true
}

plugin "azurerm" {
  enabled = true
}

plugin "google" {
  enabled = true
}
EOF

# Set ownership for the config file
chown -R vscode:vscode /home/vscode/.tflint.d

echo "Terraform tools installation complete!"
