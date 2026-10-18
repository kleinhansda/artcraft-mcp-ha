# Gemeinsame Definitionen für run.sh und artcraft-selftest.
# Hier steht, mit welchen Optionen jede App ihren MCP-Server startet.
# Ändert ein neues Release eine Option, schlägt der Selbsttest im Build fehl.

APPS=(vectorcraft photocraft pdfcraft)

declare -A PORTS=(
  [vectorcraft]=8081
  [photocraft]=8082
  [pdfcraft]=8083
)

# app_cmd <app> <arbeitsordner>: setzt das Array CMD auf den Startbefehl der App.
# PDFCRAFT_COMPACT=false schaltet bei PdfCraft die kompakte Tool-Liste ab.
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
    *)
      echo "Unbekannte App: $app" >&2; return 1 ;;
  esac
}
