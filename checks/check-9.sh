#!/usr/bin/env bash
# Etape 9 : l'ensemble est monte via Docker Compose.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 9 : Le plan d'ensemble =="
CT=$(docker ps --filter "label=com.docker.compose.project" --format '{{.Names}}')
if [ -n "$CT" ]; then ok "Un ensemble Compose tourne :"; echo "$CT" | sed 's/^/     - /'
else ko "Aucun ensemble Compose detecte (docker compose up -d)."; fi
if curl -s --max-time 4 http://localhost:3000/health | grep -q '"redis":true'; then ok "L'app repond et range ses registres dans l'entrepot."; fi
finish
