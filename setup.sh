#!/usr/bin/env bash
# Einmalig (und bei jedem Core-Update erneut) ausfuehren:
#   bash setup.sh
set -euo pipefail

MOODLE_BRANCH="MOODLE_502_STABLE"   # Moodle 5.2 - noetig fuer format_flexsections >= 5.0
                                     # (vorher: MOODLE_405_STABLE / 4.5 LTS bis Okt. 2027 --
                                     # bewusst auf 5.2 hochgezogen, da die 4.5-kompatible
                                     # Plugin-Version (4.1.6) auf dem 4.5-Server nicht mehr
                                     # zum Marketplace-Standarddownload passte)

# Wechselt einen bestehenden Checkout auf einen anderen Branch, falls
# MOODLE_BRANCH/Plugin-Branch sich geaendert hat (z.B. Versions-Upgrade).
# WICHTIG: vor einem Branch-Wechsel selbst sichern (Backup!) -- das hier
# macht keinen Rueckwaerts-Kompatibilitaets-Check, nur den Code-Wechsel.
checkout_branch() {
  local dir="$1" branch="$2"
  local current
  current=$(git -C "$dir" rev-parse --abbrev-ref HEAD)
  if [ "$current" != "$branch" ]; then
    echo ">> ${dir}: Branch-Wechsel ${current} -> ${branch}"
    git -C "$dir" remote set-branches origin "$branch"
    git -C "$dir" fetch --depth 1 origin "$branch"
    git -C "$dir" checkout "$branch"
  fi
}

if [ ! -d "html/.git" ]; then
  echo ">> Klone Moodle-Core (${MOODLE_BRANCH})..."
  git clone --branch "${MOODLE_BRANCH}" --depth 1 https://github.com/moodle/moodle.git html
else
  checkout_branch html "${MOODLE_BRANCH}"
  echo ">> html/ - hole Core-Updates:"
  (cd html && git pull)
fi

# Zusatz-Plugins, die nicht Teil des Moodle-Core-Clones sind (eigener
# Clone pro Plugin nach html/<pfad>/, damit sie bei Core-Updates nicht
# ueberschrieben werden -- html/ ist gitignored, dieses Skript ist die
# einzige Quelle der Wahrheit dafuer, was installiert wird).
declare -A PLUGINS=(
  ["course/format/flexsections"]="https://github.com/marinaglancy/moodle-format_flexsections.git|MOODLE_500_STABLE"
)

for path in "${!PLUGINS[@]}"; do
  IFS='|' read -r repo branch <<< "${PLUGINS[$path]}"
  target="html/${path}"
  if [ ! -d "${target}/.git" ]; then
    echo ">> Klone Plugin nach ${target} (${branch})..."
    git clone --branch "${branch}" --depth 1 "${repo}" "${target}"
  else
    checkout_branch "${target}" "${branch}"
    echo ">> ${target} - hole Updates:"
    (cd "${target}" && git pull)
  fi
done

echo ">> Fertig. Weiter mit:"
echo "   cp .env.example .env   # falls noch nicht geschehen, dann Passwoerter eintragen"
echo "   docker compose up -d --build"
echo "   Danach im Browser: Website-Administration -> Benachrichtigungen aufrufen,"
echo "   damit Moodle neue/aktualisierte Plugins installiert (auch nach jedem erneuten setup.sh)."
