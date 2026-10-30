#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if [ -e .env ]; then
  echo '.env already exists; keeping it unchanged'
  exit 0
fi
umask 077
printf 'REDIS_PASSWORD=%s\n' "$(openssl rand -hex 32)" > .env
chmod 600 .env
echo '.env created with mode 600; secret is not printed'
