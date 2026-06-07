#!/bin/bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

if [[ -f config/aws.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source config/aws.env
  set +a
fi

export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION="${AWS_REGION:-us-east-1}"

# Override in config/aws.env to pin models for your account/region.
export ANTHROPIC_DEFAULT_SONNET_MODEL="${ANTHROPIC_DEFAULT_SONNET_MODEL:-us.anthropic.claude-sonnet-4-6}"
export ANTHROPIC_DEFAULT_OPUS_MODEL="${ANTHROPIC_DEFAULT_OPUS_MODEL:-us.anthropic.claude-opus-4-8}"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="${ANTHROPIC_DEFAULT_HAIKU_MODEL:-us.anthropic.claude-haiku-4-5-20251001-v1:0}"

if ! command -v claude >/dev/null 2>&1; then
  echo "Claude Code is not installed. Rebuild the dev container and try again." >&2
  exit 1
fi

exec claude "$@"
