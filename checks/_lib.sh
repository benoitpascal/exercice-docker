# Petite bibliotheque commune aux scripts de verification.
GREEN=$'\033[0;32m'; RED=$'\033[0;31m'; YEL=$'\033[0;33m'; NC=$'\033[0m'
ok()   { echo "${GREEN}OK${NC}   $1"; }
ko()   { echo "${RED}A REVOIR${NC} $1"; FAIL=1; }
info() { echo "${YEL}>${NC} $1"; }
need_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "${RED}Docker n'est pas installe ou pas dans le PATH.${NC}"
    exit 1
  fi
}
finish() {
  echo
  if [ "${FAIL:-0}" -eq 0 ]; then
    echo "${GREEN}Mission validee. Tu peux passer a la suite.${NC}"
  else
    echo "${RED}Pas encore. Relis l'objectif et les indices de la mission.${NC}"
    exit 1
  fi
}
