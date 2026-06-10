#!/usr/bin/env bash
# Etape 2 : image mon-app-custom:1.0 construite et conteneur 'app' demarre.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 2 : Ton propre etablissement =="
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^mon-app-custom:1.0$'; then ok "Plan construit : image mon-app-custom:1.0."
else ko "Image mon-app-custom:1.0 introuvable (docker build -t)."; fi
HIT=0; for id in $(docker ps -q); do docker inspect --format '{{.Config.Image}}' "$id" 2>/dev/null | grep -q '^mon-app-custom:1.0$' && HIT=1; done
if [ "$HIT" = 1 ]; then ok "Un batiment est ouvert a partir de ton image."
else ko "Aucun batiment ouvert base sur mon-app-custom:1.0."; fi
finish
