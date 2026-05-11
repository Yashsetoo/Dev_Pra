# Kubesimplify-CI-CD

Python Flask app deployed with this flow:

git push -> GitHub Actions -> Docker build -> ECR push -> SSM send-command -> EC2 docker pull + run

## App

- `GET /` returns the `MSG` environment variable.
- `GET /health` returns `{"status":"healthy"}` for Docker health checks.
- The app listens on `PORT`, default `5000`.

## SSM Parameter Store

This app does not use a database right now, so you do not need `DATABASE_URL`.

Create these parameters in AWS Systems Manager Parameter Store:

| Path | Type | Example |
| --- | --- | --- |
| `/myapp/prod/MSG` | `String` | `Hello from EC2` |
| `/myapp/prod/PORT` | `String` | `5000` |

Use `SecureString` for secrets such as API keys, tokens, passwords, and database URLs. Use `String` for non-secret config like `PORT`.

## GitHub Secrets

Create these repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `EC2_INSTANCE_ID`
- `ECR_REPOSITORY`

## Workflow Settings

Edit `.github/workflows/deploy.yml`:

- `SSM_PARAMETER_PATH`: your SSM path, for example `/myapp/prod`
- `HOST_PORT`: EC2 host port, usually `80`
- `CONTAINER_PORT`: container port, usually `5000`

## EC2 Requirements

The EC2 instance needs:

- Docker installed and running
- AWS CLI installed
- SSM Agent installed and online
- IAM role permissions for SSM, ECR pull, and `ssm:GetParametersByPath`
