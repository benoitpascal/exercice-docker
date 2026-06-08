#!/usr/bin/env bash
# Mission 3 : image pixel-counter:1.0 construite, conteneur 'compteur' sur 3000.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 3 : ta propre image =="
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^pixel-counter:1.0$'; then
  ok "L'image pixel-counter:1.0 existe."
else ko "Image pixel-counter:1.0 introuvable (option -t lors du build ?)."; fi
if [ "$(docker ps --filter "name=^compteur$" --format '{{.Names}}')" = "compteur" ]; then
  ok "Le conteneur 'compteur' tourne."
else ko "Aucun conteneur en marche nomme 'compteur'."; fi
BODY=$(curl -s --max-time 5 http://localhost:3000)
if echo "$BODY" | grep -qi 'visite'; then ok "L'app repond sur http://localhost:3000."
else ko "Rien ne repond sur http://localhost:3000 (port publie ?)."; fi
if curl -s --max-time 5 http://localhost:3000/health | grep -q '"redis":false'; then
  ok "Mode degrade attendu a ce stade (pas encore de Redis), c'est normal."
fi
finish
