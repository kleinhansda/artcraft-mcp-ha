#!/bin/bash
# Startet je App mit eingetragener URL einen mcp-auth-proxy, der den MCP-Server der App
# über stdio anbindet. Stürzt ein Dienst ab, startet ihn seine Schleife neu,
# die anderen Apps laufen weiter.
set -euo pipefail

# shellcheck source=rootfs/usr/local/lib/artcraft/apps.sh
source /usr/local/lib/artcraft/apps.sh

OPTS="${ARTCRAFT_OPTIONS:-/data/options.json}"   # für Tests überschreibbar
DATA="${ARTCRAFT_DATA:-/data}"

log()    { echo "[artcraft] $*"; }
fehler() { echo "[artcraft] FEHLER: $*" >&2; exit 1; }
opt()    { jq -r --arg k "$1" '.[$k] // "" | tostring' "$OPTS"; }

[ -f "$OPTS" ] || fehler "$OPTS fehlt"

OIDC_CONFIGURATION_URL="$(opt oidc_configuration_url)"
OIDC_CLIENT_ID="$(opt oidc_client_id)"
OIDC_CLIENT_SECRET="$(opt oidc_client_secret)"
OIDC_ALLOWED_USERS="$(opt oidc_allowed_users)"
PROVIDER="$(opt oidc_provider_name)"
WORK="$(opt work_dir)"
LEGACY="$(opt legacy_auth_dir)"
PDFCRAFT_COMPACT="$(opt pdfcraft_compact)"

[ -n "$OIDC_CONFIGURATION_URL" ] || fehler "oidc_configuration_url ist leer"
[ -n "$OIDC_CLIENT_ID" ]         || fehler "oidc_client_id ist leer"
[ -n "$OIDC_CLIENT_SECRET" ]     || fehler "oidc_client_secret ist leer"
[ -n "$WORK" ]                   || fehler "work_dir ist leer"

# Der Proxy liest die OIDC-Werte aus der Umgebung (so taucht das Secret nicht in der
# Prozessliste auf). Die Apps selbst bekommen die Werte nicht, siehe "env -u" unten.
export OIDC_CONFIGURATION_URL OIDC_CLIENT_ID OIDC_CLIENT_SECRET PDFCRAFT_COMPACT
if [ -n "$OIDC_ALLOWED_USERS" ]; then export OIDC_ALLOWED_USERS; fi
export HOME=/tmp

mkdir -p "$WORK"
log "Versionen:"
sed 's/^/[artcraft]   /' /usr/local/share/artcraft-versions
log "Arbeitsordner: $WORK"

dienst() {
  local app=$1 url=$2 port=${PORTS[$1]} data="$DATA/$1" pause=5 start
  mkdir -p "$data"

  # Einmalige Übernahme der Proxy-Daten (registrierte Clients, Schlüssel) aus einer
  # früheren Installation. Dann muss Claude nicht neu verbunden werden.
  if [ -n "$LEGACY" ] && [ -d "$LEGACY/$app" ] && [ -z "$(ls -A "$data")" ]; then
    cp -a "$LEGACY/$app/." "$data/"
    log "$app: Proxy-Daten aus $LEGACY/$app übernommen"
  fi

  app_cmd "$app" "$WORK"
  while true; do
    start=$SECONDS
    log "$app: Start auf Port $port für $url"
    mcp-auth-proxy \
      --listen ":$port" \
      --external-url "$url" \
      --no-auto-tls \
      --data-path "$data" \
      --oidc-provider-name "$PROVIDER" \
      -- env -u OIDC_CLIENT_SECRET -u OIDC_CLIENT_ID -u OIDC_CONFIGURATION_URL -u OIDC_ALLOWED_USERS \
      "${CMD[@]}" 2>&1 | sed -u "s/^/[$app] /" || true
    # Länger gelaufen: kurz warten. Sofort wieder beendet: Pause verdoppeln, höchstens 60 s.
    if (( SECONDS - start > 60 )); then pause=5; elif (( pause < 60 )); then pause=$(( pause * 2 )); fi
    log "$app: beendet, Neustart in ${pause} s"
    sleep "$pause"
  done
}

beenden() {
  trap '' TERM INT
  log "Stoppe Dienste"
  kill -TERM 0 2>/dev/null || true
  wait || true
  exit 0
}
trap beenden TERM INT

n=0
for app in "${APPS[@]}"; do
  url="$(opt "${app}_url")"
  if [ -n "$url" ]; then
    dienst "$app" "${url%/}" &
    n=$(( n + 1 ))
  else
    log "$app: keine URL eingetragen, wird nicht gestartet"
  fi
done
[ "$n" -gt 0 ] || fehler "Keine App aktiviert. Mindestens eine der URLs eintragen."

wait
