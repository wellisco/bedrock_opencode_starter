# Dev container for OpenCode + Claude Code on Amazon Bedrock.
# Credentials are NOT copied from the host — users configure AWS inside the container
# (see scripts/setup-aws.sh and config/aws.env.example).

FROM mcr.microsoft.com/devcontainers/base:ubuntu

USER root

# Base tools for git, downloads, and the AWS CLI installer.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        ripgrep \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 — used by setup-aws.sh, verify-aws.sh, and the credential chain
# for OpenCode / Claude Code Bedrock calls.
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Install AI CLIs as the non-root dev user (matches devcontainer.json remoteUser).
USER vscode

# opencode -> ~/.opencode/bin
# claude  -> ~/.local/bin
ENV PATH="/home/vscode/.opencode/bin:/home/vscode/.local/bin:/usr/local/bin:${PATH}"

RUN curl -fsSL https://opencode.ai/install | bash
# RUN curl -fsSL https://claude.ai/install.sh | bash
