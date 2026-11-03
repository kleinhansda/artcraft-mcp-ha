# shellcheck shell=bash disable=SC2034  # wird von run.sh und artcraft-selftest eingebunden
# Gemeinsame Definitionen für run.sh und artcraft-selftest.
# Hier steht, mit welchen Optionen jede App ihren MCP-Server startet.
# Ändert ein neues Release eine Option, schlägt der Selbsttest im Build fehl.

APPS=(vectorcraft photocraft pdfcraft cadcraft wordcraft deckcraft gridcraft figcraft craft-anything files)

declare -A PORTS=(
  [vectorcraft]=8081
  [photocraft]=8082
  [pdfcraft]=8083
  [cadcraft]=8085
  [wordcraft]=8086
  [deckcraft]=8087
  [gridcraft]=8088
  [figcraft]=8089
  [craft-anything]=8090
  [files]=8084
)

# Interner Zugriff ohne Anmeldung (internal_apps): je App Port + 1000, also 9081 bis 9090.
# Diese Ports stehen bewusst nicht in config.yaml und werden nie auf den Host gelegt.
declare -A INTERNAL_PORTS=()
for _app in "${!PORTS[@]}"; do INTERNAL_PORTS[$_app]=$(( PORTS[$_app] + 1000 )); done
unset _app

# app_cmd <app> <arbeitsordner>: setzt das Array CMD auf den Startbefehl der App.
# PDFCRAFT_COMPACT=false schaltet bei PdfCraft die kompakte Tool-Liste ab.
# WordCraft, DeckCraft und FigCraft begrenzen den Dateizugriff der Tools auf den
# Arbeitsordner (--automation-read-root/--write-root). CADCraft, GridCraft und
# Craft Anything bieten diese Optionen nicht, ihre Tools sind nicht begrenzt.
app_cmd() {
  local app=$1 work=$2
  case "$app" in
    vectorcraft)
      CMD=(vectorcraft-cli mcp --headless --automation-read-root "$work" --automation-write-root "$work") ;;
    photocraft)
      CMD=(photocraft-cli mcp --automation-read-root "$work" --automation-write-root "$work") ;;
    pdfcraft)
      CMD=(pdfcraft-cli mcp --root "$work")
      if [ "${PDFCRAFT_COMPACT:-true}" = true ]; then CMD+=(--compact); fi ;;
    cadcraft)
      CMD=(cadcraft-cli mcp) ;;
    wordcraft)
      CMD=(wordcraft-cli mcp --automation-read-root "$work" --automation-write-root "$work") ;;
    deckcraft)
      CMD=(deckcraft-cli mcp --automation-read-root "$work" --automation-write-root "$work") ;;
    gridcraft)
      CMD=(gridcraft-cli mcp) ;;
    figcraft)
      CMD=(figcraft-cli mcp --automation-read-root "$work" --automation-write-root "$work") ;;
    craft-anything)
      CMD=(craft-anything-cli mcp) ;;
    files)
      CMD=(python3 /usr/local/lib/artcraft/files_mcp.py "$work") ;;
    *)
      echo "Unbekannte App: $app" >&2; return 1 ;;
  esac
}
