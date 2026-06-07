#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/config/aws.env"

export PATH="$HOME/.opencode/bin:$PATH"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

echo "=== AWS identity ==="
aws sts get-caller-identity

echo
echo "=== Bedrock (${AWS_REGION:-us-east-1}) ==="
model_count="$(aws bedrock list-foundation-models \
  --region "${AWS_REGION:-us-east-1}" \
  --query 'length(modelSummaries)' \
  --output text)"

echo "Found $model_count foundation models in this region."

if [[ ! -f "$ROOT/opencode.json" ]]; then
  echo
  echo "Tip: copy opencode.json.example to opencode.json for Bedrock defaults."
fi

if command -v opencode >/dev/null 2>&1; then
  echo
  echo "OpenCode: $(opencode --version)"
  echo "Run ./run.sh to start, then use /models inside OpenCode."
else
  echo
  echo "OpenCode is not installed yet. Rebuild the dev container."
fi

if command -v claude >/dev/null 2>&1; then
  echo
  echo "Claude Code: $(claude --version 2>/dev/null || echo installed)"
  echo "Run ./run-claude.sh to start Claude Code on Bedrock."
else
  echo
  echo "Claude Code is not installed yet. Rebuild the dev container."
fi
