#!/bin/bash
set -euo pipefail

export PATH="$HOME/.opencode/bin:$PATH"

if [[ -f config/aws.env ]]; then
  set -a
  # shellcheck disable=SC1091
  source config/aws.env
  set +a
fi

exec opencode "$@"
