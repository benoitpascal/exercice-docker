#!/usr/bin/env bash
# Mission 6 : volume pixel-data monte dans le conteneur cache sur /data.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 6 : persistance des donnees =="
if docker volume ls --format '{{.Name}}' | grep -q '^pixel-data$'; then
  ok "Le volume 'pixel-data' existe."
else ko "Volume 'pixel-data' introuvable."; fi
MOUNTS=$(docker inspect cache --format '{{range .Mounts}}{{.Name}}:{{.Destination}} {{end}}' 2>/dev/null)
if echo "$MOUNTS" | grep -q 'pixel-data:/data'; then
  ok "Le volume 'pixel-data' est monte sur /data dans 'cache'."
else
  ko "Le volume n'est pas monte sur /data du conteneur 'cache'."
  info "Vu actuellement : ${MOUNTS:-aucun montage}"
fi
finish
