#!/usr/bin/env bash
# Etape 1 : un batiment d'accueil est ouvert.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 1 : Accueillir les bateaux =="
if [ -n "$(docker ps -q)" ]; then ok "Au moins un batiment est ouvert sur le port."
else ko "Aucun batiment ouvert. Lance un service avec docker run (image nginx)."; fi
finish
