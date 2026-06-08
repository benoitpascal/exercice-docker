#!/usr/bin/env bash
# Mission 4 : message personnalise via APP_MESSAGE.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Mission 4 : configuration par variable =="
BODY=$(curl -s --max-time 5 http://localhost:3000)
if [ -z "$BODY" ]; then ko "L'app ne repond pas sur 3000."; finish; fi
H1=$(echo "$BODY" | grep -o '<h1>[^<]*</h1>' | head -1 | sed 's/<[^>]*>//g')
if [ -n "$H1" ] && [ "$H1" != "Bonjour le monde" ]; then
  ok "Message personnalise detecte : \"$H1\" (via APP_MESSAGE)."
else
  ko "Le message est encore celui par defaut. Passe APP_MESSAGE au lancement."
fi
finish
