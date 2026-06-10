#!/usr/bin/env bash
# Etape 8 : apres une fermeture/reouverture, le conteneur maritime tient toujours.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 8 : Encaisser une coupure =="
HIT=0; for id in $(docker ps -q); do docker inspect --format '{{range .Mounts}}{{.Type}} {{end}}' "$id" 2>/dev/null | grep -q 'volume' && HIT=1; done
if [ "$HIT" = 1 ]; then ok "Un batiment ouvert garde son conteneur maritime : les donnees survivent aux fermetures."
else ko "Aucun batiment ouvert avec un conteneur maritime."; fi
info "Teste-le toi-meme : note le total, stop puis start le conteneur, recharge la page."
finish
