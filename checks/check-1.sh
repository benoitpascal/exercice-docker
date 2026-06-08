#!/usr/bin/env bash
# Mission 1 : conteneur nginx 'vitrine' en arriere-plan, publie sur 8080.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 1 : premier conteneur =="
RUNNING=$(docker ps --filter "name=^vitrine$" --format '{{.Names}}')
if [ "$RUNNING" = "vitrine" ]; then ok "Le conteneur 'vitrine' tourne."
else ko "Aucun conteneur en marche nomme 'vitrine'."; fi
PORTS=$(docker ps --filter "name=^vitrine$" --format '{{.Ports}}')
if echo "$PORTS" | grep -q '8080'; then ok "Le port 8080 est publie."
else ko "Le port 8080 ne semble pas publie (option de publication ?)."; fi
if curl -s --max-time 5 http://localhost:8080 | grep -qi 'nginx'; then
  ok "La page nginx repond sur http://localhost:8080."
else ko "Rien ne repond sur http://localhost:8080."; fi
finish
