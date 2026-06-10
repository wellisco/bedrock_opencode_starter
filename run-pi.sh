#!/bin/bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

if [[ -f config/aws.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source config/aws.env
  set +a
fi

export AWS_REGION="${AWS_REGION:-us-east-1}"

# Pi checks env vars for Bedrock auth; it does not infer ~/.aws/credentials alone.
if [[ -z "${AWS_PROFILE:-}" && -z "${AWS_ACCESS_KEY_ID:-}" && -z "${AWS_BEARER_TOKEN_BEDROCK:-}" ]]; then
  if [[ -f "$HOME/.aws/credentials" ]]; then
    export AWS_PROFILE=default
  fi
fi

# Bedrock defaults (override in config/aws.env)
PI_PROVIDER="${PI_PROVIDER:-amazon-bedrock}"
PI_MODEL="${PI_MODEL:-us.anthropic.claude-sonnet-4-6}"

if ! command -v pi >/dev/null 2>&1; then
  echo "Pi is not installed. Rebuild the dev container and try again." >&2
  exit 1
fi

args=(--approve)
has_provider=false
has_model=false

for arg in "$@"; do
  case "$arg" in
    --provider|--provider=*)
      has_provider=true
      ;;
    --model|--model=*)
      has_model=true
      ;;
  esac
done

if [[ "$has_provider" == false ]]; then
  args+=(--provider "$PI_PROVIDER")
fi

if [[ "$has_model" == false ]]; then
  args+=(--model "$PI_MODEL")
fi

args+=("$@")

exec pi "${args[@]}"
