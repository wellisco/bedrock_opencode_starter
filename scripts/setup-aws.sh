#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT/config/aws.env"
ENV_EXAMPLE="$ROOT/config/aws.env.example"
OPENCODE_EXAMPLE="$ROOT/opencode.json.example"
OPENCODE_CONFIG="$ROOT/opencode.json"

usage() {
  cat <<'EOF'
Configure AWS credentials inside this dev container.

Usage:
  ./scripts/setup-aws.sh          Interactive setup
  ./scripts/setup-aws.sh --check  Verify existing credentials only

Credentials are stored in the container filesystem (~/.aws or config/aws.env).
Nothing is read from or written to your host machine's ~/.aws directory.
EOF
}

check_only=false
if [[ "${1:-}" == "--check" || "${1:-}" == "--check-only" ]]; then
  check_only=true
fi

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v aws >/dev/null 2>&1; then
  echo "AWS CLI is not installed. Rebuild the dev container and try again." >&2
  exit 1
fi

verify_credentials() {
  echo "Checking AWS credentials..."
  aws sts get-caller-identity
  echo
  echo "Checking Bedrock access in ${AWS_REGION:-us-east-1}..."
  aws bedrock list-foundation-models --region "${AWS_REGION:-us-east-1}" --query 'modelSummaries[0].modelId' --output text >/dev/null
  echo "Bedrock API access looks good."
}

if $check_only; then
  if [[ -f "$ENV_FILE" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
  fi
  verify_credentials
  exit 0
fi

echo "OpenCode AWS setup"
echo "=================="
echo
echo "This container does NOT mount your host ~/.aws folder."
echo "Credentials you enter here stay inside the container."
echo

mkdir -p "$ROOT/config"

echo "Choose an authentication method:"
echo "  1) AWS access key (IAM user)"
echo "  2) AWS SSO profile"
echo "  3) Skip — I will create config/aws.env manually"
read -r -p "Choice [1-3]: " auth_choice

case "$auth_choice" in
  1)
    read -r -p "AWS region [us-east-1]: " aws_region
    aws_region="${aws_region:-us-east-1}"
    aws configure set region "$aws_region"
    echo "Enter your IAM access key (input is hidden for the secret):"
    aws configure
    export AWS_REGION="$aws_region"
    ;;
  2)
    read -r -p "Profile name [default]: " profile_name
    profile_name="${profile_name:-default}"
    aws configure sso --profile "$profile_name"
    aws sso login --profile "$profile_name"
    read -r -p "AWS region [us-east-1]: " aws_region
    aws_region="${aws_region:-us-east-1}"

    cat >"$ENV_FILE" <<EOF
AWS_PROFILE=$profile_name
AWS_REGION=$aws_region
EOF
    chmod 600 "$ENV_FILE"
    export AWS_PROFILE="$profile_name"
    export AWS_REGION="$aws_region"
    ;;
  3)
    if [[ ! -f "$ENV_FILE" ]]; then
      cp "$ENV_EXAMPLE" "$ENV_FILE"
      echo "Created $ENV_FILE — edit it, then run: ./scripts/verify-aws.sh"
    else
      echo "Using existing $ENV_FILE"
    fi
    exit 0
    ;;
  *)
    echo "Invalid choice." >&2
    exit 1
    ;;
esac

if [[ ! -f "$OPENCODE_CONFIG" ]]; then
  cp "$OPENCODE_EXAMPLE" "$OPENCODE_CONFIG"
  echo "Created opencode.json from opencode.json.example"
fi

echo
verify_credentials

cat <<'EOF'

Setup complete.

Next steps:
  1. Enable model access in the Bedrock console (Model access / Model catalog).
  2. Run: ./run.sh
  3. Inside OpenCode, run: /models  and pick a Bedrock model.

EOF
