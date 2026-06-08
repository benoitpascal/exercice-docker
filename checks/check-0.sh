#!/usr/bin/env bash
# Phase 0 : Docker repond et le test de bienvenue est passe.
set -u; FAIL=0; DIR="$(cd "$(dirname "$0")" && pwd)"; . "$DIR/_lib.sh"
need_docker
echo "== Phase 0 : installation =="
if docker version >/dev/null 2>&1; then ok "Docker repond."
else ko "Docker ne repond pas (le service est-il demarre ?)."; fi
if docker images --format '{{.Repository}}' | grep -q '^hello-world$'; then
  ok "L'image hello-world est presente (test de bienvenue lance)."
else
  info "Image hello-world non trouvee. As-tu lance le conteneur de bienvenue ?"
fi
finish
