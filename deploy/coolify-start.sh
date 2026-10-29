#!/usr/bin/env bash
# Custom Start Command entrypoint for Coolify (see deploy/COOLIFY.md).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

bash deploy/coolify-ensure-config.sh

# Prefer mailcow.conf; .env is a copy for Coolify's injected compose step.
ENV_FILE=mailcow.conf
[ -f mailcow.conf ] || ENV_FILE=.env

COMPOSE=(docker compose --env-file "$ENV_FILE")
if [ "${DOCKER_COMPOSE_VERSION:-native}" = "standalone" ]; then
  COMPOSE=(docker-compose --env-file mailcow.conf)
fi

"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d --remove-orphans
