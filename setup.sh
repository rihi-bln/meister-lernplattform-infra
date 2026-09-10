#!/usr/bin/env bash
# Einmalig (und bei jedem Core-Update erneut) ausfuehren:
#   bash setup.sh
set -euo pipefail

MOODLE_BRANCH="MOODLE_405_STABLE"   # Moodle 4.5 LTS - Support bis Okt. 2027

if [ ! -d "html/.git" ]; then
  echo ">> Klone Moodle-Core (${MOODLE_BRANCH}, LTS)..."
  git clone --branch "${MOODLE_BRANCH}" --depth 1 https://github.com/moodle/moodle.git html
else
  echo ">> html/ existiert bereits - hole Core-Updates:"
  (cd html && git pull)
fi

echo ">> Fertig. Weiter mit:"
echo "   cp .env.example .env   # falls noch nicht geschehen, dann Passwoerter eintragen"
echo "   docker compose up -d --build"
