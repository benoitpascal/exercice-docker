#!/usr/bin/env bash
# Mission 2 : 'vitrine' arrete et supprime, port 8080 libre.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 2 : menage =="
if docker ps -a --format '{{.Names}}' | grep -q '^vitrine$'; then
  ko "Le conteneur 'vitrine' existe encore (arrete-le puis supprime-le)."
else ok "Plus aucun conteneur 'vitrine'."; fi
if curl -s --max-time 3 http://localhost:8080 >/dev/null 2>&1; then
  ko "Quelque chose repond encore sur 8080."
else ok "Le port 8080 est libre."; fi
finish
