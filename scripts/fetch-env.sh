#!/usr/bin/env sh
set -eu

PARAMETER_PATH="${PARAMETER_PATH:-/myapp/prod/MSG}"
ENV_FILE="${ENV_FILE:-.env}"
TMP_FILE="$(mktemp)"

cleanup() {
  rm -f "$TMP_FILE"
}
trap cleanup EXIT

mkdir -p "$(dirname "$ENV_FILE")"

aws ssm get-parameters-by-path \
  --path "$PARAMETER_PATH" \
  --recursive \
  --with-decryption \
  --query 'Parameters[*].[Name,Value]' \
  --output text > "$TMP_FILE"

while IFS="$(printf '\t')" read -r name value; do
  key="${name##*/}"

  case "$key" in
    ''|*[!A-Za-z0-9_]*)
      echo "Skipping invalid environment variable name from SSM: $name" >&2
      continue
      ;;
  esac

  printf '%s=%s\n' "$key" "$value"
done < "$TMP_FILE" > "$ENV_FILE"

chmod 600 "$ENV_FILE"
echo "Wrote environment file to $ENV_FILE"
