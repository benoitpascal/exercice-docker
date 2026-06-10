#!/usr/bin/env bash
# Etape 7 : deux batiments ouverts relies par un meme pont (reseau).
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 7 : Un entrepot, et un pont =="
declare -A C
for id in $(docker ps -q); do
  for n in $(docker inspect --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}} {{end}}' "$id" 2>/dev/null); do
    case "$n" in bridge|host|none) ;; *) C[$n]=$(( ${C[$n]:-0} + 1 ));; esac
  done
done
BR=""; for n in "${!C[@]}"; do [ "${C[$n]}" -ge 2 ] && BR="$n"; done
if [ -n "$BR" ]; then ok "Un pont relie au moins deux batiments : $BR."
else ko "Pas de pont reliant deux batiments ouverts (docker network create + --network)."; fi
finish
