# OpenCode + AWS Bedrock (Dev Container Starter)

A minimal, security-conscious starter for running [OpenCode](https://opencode.ai) against **Amazon Bedrock** inside an isolated dev container.

## Security model

This repo is designed for teams that do **not** want their laptop AWS credentials shared into a container.

| What | Behavior |
|------|----------|
| Host `~/.aws` | **Not mounted** — your Mac/PC credentials are never read |
| Credentials | Entered **inside the container** via AWS CLI or `config/aws.env` |
| Secrets in git | **Blocked** — `config/aws.env`, `opencode.json`, and `.aws/` are gitignored |
| Network | Container reaches AWS APIs directly using credentials you provide |

Credentials live in the container filesystem (`~/.aws` or `config/aws.env`). They are not copied from your host unless you paste them during setup.

## Quick start

### 1. Clone and open in a dev container

```bash
git clone https://github.com/YOUR_ORG/opencode-bedrock-starter.git
cd opencode-bedrock-starter
```

Open the folder in VS Code or Cursor, then run **Dev Containers: Reopen in Container**.

### 2. Enable Bedrock in AWS

In the [Amazon Bedrock console](https://console.aws.amazon.com/bedrock/):

1. Choose your region (e.g. `us-east-1`).
2. Open **Model access** (or **Model catalog**) and enable the models you need (e.g. Claude).
3. Ensure your IAM principal can call Bedrock (see [IAM permissions](#iam-permissions) below).

### 3. Configure AWS inside the container

```bash
chmod +x run.sh run-claude.sh scripts/*.sh
./scripts/setup-aws.sh
```

Or manually:

```bash
cp config/aws.env.example config/aws.env
# edit config/aws.env with your keys or profile name
cp opencode.json.example opencode.json
./scripts/verify-aws.sh
```

### 4. Run OpenCode or Claude Code

**OpenCode:**

```bash
./run.sh
```

Inside OpenCode, select a model:

```text
/models
```

**Claude Code on Bedrock:**

```bash
./run-claude.sh
```

This sets `CLAUDE_CODE_USE_BEDROCK=1`, loads credentials from `config/aws.env`, and pins default Sonnet/Opus/Haiku models. Override model IDs in `config/aws.env` if your account uses different inference profiles.

Inside Claude Code, switch models with `/model`. See [Claude Code on Amazon Bedrock](https://code.claude.com/docs/en/amazon-bedrock).

## Authentication options

OpenCode supports the standard AWS credential chain. Pick one:

**Access keys** — set in `config/aws.env`:

```bash
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-1
```

**Named profile** — configure inside the container:

```bash
aws configure --profile my-profile
export AWS_PROFILE=my-profile   # or add to config/aws.env
```

**SSO** — `./scripts/setup-aws.sh` option 2 runs `aws configure sso` and `aws sso login`.

See [OpenCode Bedrock docs](https://opencode.ai/docs/providers/#amazon-bedrock) for bearer tokens and VPC endpoints.

## IAM permissions

Your IAM user or role needs at least:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:ListFoundationModels",
        "bedrock:GetFoundationModel",
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": "*"
    }
  ]
}
```

Adjust `Resource` to specific model ARNs for least privilege. Some organizations also require `bedrock:ListInferenceProfiles` for application inference profiles.

Verify access:

```bash
./scripts/verify-aws.sh
```

## Project layout

```text
.
├── .devcontainer/          # Isolated container — no host credential mounts
├── config/
│   └── aws.env.example     # Template for local credentials (gitignored when copied)
├── scripts/
│   ├── setup-aws.sh        # Interactive credential setup
│   └── verify-aws.sh       # Test AWS + Bedrock access
├── opencode.json.example   # Bedrock provider defaults
├── run.sh                  # Start OpenCode with local config
└── run-claude.sh           # Start Claude Code on Bedrock
```

## FAQ

**Does this use my laptop’s AWS profile?**  
No. The dev container does not bind-mount `~/.aws` from your host.

**Where are credentials stored?**  
Inside the container: `~/.aws/` (from `aws configure`) and/or `config/aws.env` in the project (gitignored).

**What happens when I rebuild the container?**  
Container-local `~/.aws` is reset. Keep `config/aws.env` in the project folder (it persists on your machine via the workspace mount) or re-run `./scripts/setup-aws.sh`.

**Can we use SSO?**  
Yes. Run `./scripts/setup-aws.sh` and choose SSO, or configure a profile with `aws configure sso` inside the container.

## Links

- [Claude Code on Amazon Bedrock](https://code.claude.com/docs/en/amazon-bedrock)
- [OpenCode documentation](https://opencode.ai/docs)
- [OpenCode Amazon Bedrock provider](https://opencode.ai/docs/providers/#amazon-bedrock)
- [Amazon Bedrock model access](https://docs.aws.amazon.com/bedrock/latest/userguide/model-access.html)
- [AWS CLI configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
