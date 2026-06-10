#!/usr/bin/env bash
# Etape 10 : le plan est tague pour un entrepot central (identifiant/mon-app-custom:1.0).
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"; need_docker
echo "== Etape 10 : expedier ton plan outre-mer =="
TAG=$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E '/mon-app-custom:1\.0$' | head -1)
if [ -n "$TAG" ]; then ok "Plan tague pour l'entrepot central : $TAG"
  info "Si 'docker push $TAG' s'est termine sans erreur, ton plan est expedie."
else ko "Aucun plan de la forme identifiant/mon-app-custom:1.0 (docker tag)."; fi
finish
