#!/usr/bin/env bash
# Mission 7 : la stack tourne via Docker Compose.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 7 : orchestration avec Compose =="
COMPOSE_CT=$(docker ps --filter "label=com.docker.compose.project" --format '{{.Names}}')
if [ -n "$COMPOSE_CT" ]; then
  ok "Des conteneurs geres par Compose tournent :"
  echo "$COMPOSE_CT" | sed 's/^/     - /'
else
  ko "Aucun conteneur lance par Compose detecte (utilise 'docker compose up')."
fi
if curl -s --max-time 5 http://localhost:3000/health | grep -q '"redis":true'; then
  ok "L'app repond sur 3000 et est connectee a Redis."
else ko "L'app n'est pas joignable sur 3000 avec Redis actif."; fi
finish
