#!/usr/bin/env bash
# Etape 5 : une enseigne personnalisee via APP_MESSAGE.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 5 : L'enseigne =="
HIT=0; for id in $(docker ps -q); do docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$id" 2>/dev/null | grep -q '^APP_MESSAGE=' && HIT=1; done
if [ "$HIT" = 1 ]; then ok "Une enseigne APP_MESSAGE est posee sur un batiment ouvert."
else ko "Aucun batiment ouvert avec une variable APP_MESSAGE (option -e)."; fi
finish
