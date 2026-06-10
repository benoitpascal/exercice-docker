#!/usr/bin/env bash
# Etape 6 : un conteneur maritime (volume) est amarre a un batiment ouvert.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 6 : le conteneur maritime =="
HIT=0; for id in $(docker ps -q); do docker inspect --format '{{range .Mounts}}{{.Type}} {{end}}' "$id" 2>/dev/null | grep -q 'volume' && HIT=1; done
if [ "$HIT" = 1 ]; then ok "Un conteneur maritime (volume) est amarre a un batiment ouvert."
else ko "Aucun volume monte. Amarre app-data avec -v nom:/chemin."; fi
finish
