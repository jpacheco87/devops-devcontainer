FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Set versions as arguments
ARG TERRAFORM_VERSION="1.14.1"
ARG TERRAFORM_DOCS_VERSION="0.20.0"
ARG TFSEC_VERSION="1.28.14"
ARG TERRASCAN_VERSION="1.19.9"
ARG TFLINT_VERSION="0.60.0"
ARG TFLINT_AWS_RULESET_VERSION="0.44.0"
ARG TFLINT_AZURE_RULESET_VERSION="0.30.0"
ARG TFLINT_GCP_RULESET_VERSION="0.37.1"
ARG TERRAGRUNT_VERSION="0.93.13"
ARG TERRATEST_VERSION="0.54.0"
ARG INFRACOST_VERSION="0.10.43"
ARG CHECKOV_VERSION="3.2.495"
ARG TARGETARCH

COPY library-scripts/*.sh /tmp/library-scripts/
RUN chmod +x /tmp/library-scripts/*.sh

# Install common utilities and dependencies
USER root
RUN /tmp/library-scripts/common-utils.sh

# Install cloud CLI tools
RUN /tmp/library-scripts/cloud-cli-tools.sh

# Install Terraform and related tools
RUN export TARGETARCH=${TARGETARCH} && /tmp/library-scripts/terraform-tools.sh \
    "${TERRAFORM_VERSION}" \
    "${TERRAFORM_DOCS_VERSION}" \
    "${TFSEC_VERSION}" \
    "${TERRASCAN_VERSION}" \
    "${TFLINT_VERSION}" \
    "${TFLINT_AWS_RULESET_VERSION}" \
    "${TFLINT_AZURE_RULESET_VERSION}" \
    "${TFLINT_GCP_RULESET_VERSION}" \
    "${TERRAGRUNT_VERSION}" \
    "${TERRATEST_VERSION}" \
    "${INFRACOST_VERSION}" \
    "${CHECKOV_VERSION}"

# Install Packer
RUN PACKER_VERSION=1.14.3 && \
    curl -L https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${TARGETARCH}.zip -o /tmp/packer.zip && \
    unzip -q -o /tmp/packer.zip -d /tmp && \
    mv /tmp/packer /usr/bin/ && \
    rm /tmp/packer.zip

COPY scripts /home/vscode/.devcontainer/scripts
COPY config /home/vscode/.devcontainer/config
RUN chmod +x /home/vscode/.devcontainer/scripts/*.sh
RUN chown -R vscode:vscode /home/vscode/.devcontainer

# Set up Terraform plugin cache directory
RUN mkdir -p /home/vscode/.terraform.d/plugin-cache \
    && chown -R vscode:vscode /home/vscode/.terraform.d

# Set up credential directories
RUN mkdir -p /home/vscode/.aws \
    && mkdir -p /home/vscode/.azure \
    && mkdir -p /home/vscode/.config/gcloud \
    && mkdir -p /home/vscode/.ssh \
    && chown -R vscode:vscode /home/vscode/.aws \
    && chown -R vscode:vscode /home/vscode/.azure \
    && chown -R vscode:vscode /home/vscode/.config \
    && chown -R vscode:vscode /home/vscode/.ssh \
    && chmod 700 /home/vscode/.ssh

# Clean up
RUN apt-get clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/library-scripts

COPY post-start.sh /usr/local/bin/post-start
RUN chmod +x /usr/local/bin/post-start

# Switch back to vscode user
USER vscode
