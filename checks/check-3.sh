#!/usr/bin/env bash
# Etape 3 : le batiment d'accueil 'accueil' a ete ferme et evacue.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 3 : Faire le menage =="
if docker ps -a --format '{{.Names}}' | grep -q '^accueil$'; then
  ko "Le batiment 'accueil' existe encore. Ferme-le (stop) puis evacue-le (rm)."
else ok "Le batiment 'accueil' a bien ete evacue."; fi
finish
