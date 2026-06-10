#!/usr/bin/env bash
# Etape 4 : un quai est ouvert (un batiment publie un port).
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 4 : Ouvrir un quai =="
if docker ps --format '{{.Ports}}' | grep -q '\->'; then ok "Un quai est ouvert (port publie)."
else ko "Aucun quai ouvert. Republie le port a l'ouverture du batiment (-p)."; fi
if curl -s --max-time 4 http://localhost:3000 | grep -qi 'visite'; then ok "Ton app repond sur http://localhost:3000."
else info "Rien sur localhost:3000 : c'est bien le quai 3000 que tu as ouvert ?"; fi
finish
