# Dev container for OpenCode, Pi, and Claude Code on Amazon Bedrock.
# Credentials are NOT copied from the host — users configure AWS inside the container
# (see scripts/setup-aws.sh and config/aws.env.example).

FROM ubuntu:24.04

USER root

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Ubuntu 24.04 ships a default 'ubuntu' user at UID 1000; replace it so vscode
# matches devcontainer volume ownership (remoteUser in devcontainer.json).
RUN if id ubuntu >/dev/null 2>&1; then userdel -r ubuntu; fi \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME \
    && apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
        sudo \
        git \
        curl \
        ca-certificates \
        ripgrep \
        unzip \
        xz-utils \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# AWS CLI v2 — used by setup-aws.sh, verify-aws.sh, and the credential chain
# for OpenCode / Claude Code Bedrock calls.
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o /tmp/awscliv2.zip \
    && unzip -q /tmp/awscliv2.zip -d /tmp \
    && /tmp/aws/install \
    && rm -rf /tmp/aws /tmp/awscliv2.zip

# Node.js 24 (Active LTS) — required by the Pi coding agent installer (https://pi.dev).
RUN ARCH="$(uname -m)" \
    && case "$ARCH" in \
         x86_64) NODE_ARCH=x64 ;; \
         aarch64|arm64) NODE_ARCH=arm64 ;; \
         *) echo "unsupported architecture: $ARCH" >&2; exit 1 ;; \
       esac \
    && NODE_DIST=https://nodejs.org/dist/latest-v24.x \
    && NODE_FILE="$(curl -fsSL "$NODE_DIST/SHASUMS256.txt" | awk -v suffix="-linux-${NODE_ARCH}.tar.xz" \
         'index($2, "node-v") == 1 && length($2) >= length(suffix) && substr($2, length($2) - length(suffix) + 1) == suffix { print $2; exit }')" \
    && curl -fsSL "$NODE_DIST/$NODE_FILE" -o /tmp/node.tar.xz \
    && tar -xJf /tmp/node.tar.xz -C /usr/local --strip-components=1 \
    && rm /tmp/node.tar.xz

# Install AI CLIs as the non-root dev user (matches devcontainer.json remoteUser).
USER vscode

# opencode -> ~/.opencode/bin
# pi      -> ~/.local/bin
# claude  -> ~/.local/bin
ENV PATH="/home/vscode/.opencode/bin:/home/vscode/.local/bin:/usr/local/bin:${PATH}"

RUN curl -fsSL https://opencode.ai/install | bash
ENV TERM=dumb
RUN curl -fsSL https://pi.dev/install.sh | sh
# RUN curl -fsSL https://claude.ai/install.sh | bash
