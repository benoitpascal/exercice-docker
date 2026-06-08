#!/usr/bin/env bash
# Mission 5 : reseau pixel-net, conteneur cache, app connectee a Redis.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 5 : deux conteneurs qui se parlent =="
if docker network ls --format '{{.Name}}' | grep -q '^pixel-net$'; then
  ok "Le reseau 'pixel-net' existe."
else ko "Reseau 'pixel-net' introuvable."; fi
if [ "$(docker ps --filter "name=^cache$" --format '{{.Names}}')" = "cache" ]; then
  ok "Le conteneur Redis 'cache' tourne."
else ko "Aucun conteneur en marche nomme 'cache'."; fi
if curl -s --max-time 5 http://localhost:3000/health | grep -q '"redis":true'; then
  ok "L'app est bien connectee a Redis (plus de mode degrade)."
else ko "L'app ne voit pas Redis (meme reseau ? REDIS_HOST = nom du conteneur ?)."; fi
finish
