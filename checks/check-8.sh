#!/usr/bin/env bash
# Mission 8 : image taguee pour un registry (identifiant/pixel-counter:1.0).
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 8 : publication sur un registry =="
TAG=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '/pixel-counter:1\.0$' | head -1)
if [ -n "$TAG" ]; then
  ok "Image taguee pour un registry : $TAG"
  info "Si 'docker push $TAG' s'est termine sans erreur, ton image est en ligne."
else
  ko "Aucune image de la forme 'identifiant/pixel-counter:1.0'."
  info "Re-tague ton image avec ton identifiant de registry avant de pousser."
fi
finish
