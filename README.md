# ArtCraft MCP für Home Assistant

Home-Assistant-Add-on (App), das VectorCraft, PhotoCraft, PdfCraft, CADCraft, WordCraft,
DeckCraft, GridCraft, FigCraft und Craft Anything (plus einen Datei-Server für den
Arbeitsordner) von [storytold](https://github.com/storytold) als Remote-MCP-Server für Claude
bereitstellt. Login über einen OIDC-Anbieter (z. B. Pocket ID) mit
[mcp-auth-proxy](https://github.com/sigbit/mcp-auth-proxy), Zugang z. B. über das
Cloudflared-Add-on. Optional zusätzlich intern ohne Login, z. B. für Open WebUI auf demselben
Home Assistant.

[![Repository in Home Assistant hinzufügen](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fkleinhansda%2Fartcraft-mcp-ha)

Oder von Hand: Einstellungen → Apps (Add-ons) → App Store → ⋮ → Repositories →
`https://github.com/kleinhansda/artcraft-mcp-ha`

## Inhalt

| Pfad | Inhalt |
|---|---|
| [`artcraft_mcp/DOCS.md`](artcraft_mcp/DOCS.md) | Einrichtung, Konfiguration, Updates, Fehlerbehebung (auch in Home Assistant sichtbar) |
| [`artcraft_mcp/CHANGELOG.md`](artcraft_mcp/CHANGELOG.md) | Versionen |
| [`docs/NOTIZEN.md`](docs/NOTIZEN.md) | Hintergrund: Apps im Vergleich, Testergebnisse, Ressourcen, verworfene Varianten |
| `artcraft_mcp/Dockerfile` | Image: Debian, Release-Binaries mit Prüfsummen, feste Versionen |
| `artcraft_mcp/rootfs/usr/local/lib/artcraft/files_mcp.py` | Kleiner MCP-Server für den Arbeitsordner (`files_list`, `file_get`, `file_put`) |
| `artcraft_mcp/rootfs/usr/local/lib/artcraft/mcp_bridge.py` | Brücke stdio → Streamable HTTP ohne Login für den internen Zugriff |
| `artcraft_mcp/rootfs/run.sh` | Startet je App Proxy und/oder Brücke, startet abgestürzte Dienste einzeln neu |
| `artcraft_mcp/rootfs/usr/local/lib/artcraft/apps.sh` | Startbefehle und Ports der Apps |
| `.github/workflows/update.yml` | Prüft täglich neue Releases, testet und erhöht dann die Version |

## Beschreibungen für MCP-Verbindungen

Texte zum Einfügen in das Feld **Beschreibung** einer MCP-Verbindung (Open WebUI) oder eines
Connectors. Das Modell liest sie, um zu entscheiden, welches Werkzeug es nutzt. Pfade gelten für
den Standard-Arbeitsordner `/share/artcraft/work`, bei anderem `work_dir` anpassen.

Die **Filterliste** blendet Tools aus, die nur mit der Desktop-App funktionieren (im Add-on läuft
keine Oberfläche). In Open WebUI ins Feld *Filterliste für Funktionsnamen* eintragen. Ob `!` dort
ausschließt, im Tooltip prüfen, sonst die Tools im Modell abwählen.

Tool-Listen geprüft am 2026-11-03 mit den Versionen aus Add-on 1.3.0.

### VectorCraft (`craft-vector`, Port 9081)

```
VectorCraft: Vektorgrafik wie Illustrator, z. B. Etiketten, Logos, Flyer. Dokumente öffnen (svg, pdf, ai, png, jpg), Formen, Pfade, Text, Effekte und Pathfinder anwenden, mit render_preview prüfen, mit save_file oder export (svg, pdf, png) sichern. Dateien nur unter /share/artcraft/work. Ein geöffnetes Dokument für alle Chats, Ergebnisse immer speichern. Weitere Befehle über list_commands und run_command.
```

Filterliste: `!ui_inspect, !ui_screenshot, !inspect_ui, !select_tool, !pointer_gesture, !press_key, !type_text, !answer_dialog, !invoke_menu, !open_panel`

### PhotoCraft (`craft-photo`, Port 9082)

```
PhotoCraft: Bildbearbeitung wie Photoshop. Bilder und PSD öffnen (doc_open), Ebenen, Filter, Korrekturen und Zuschnitt über command_run und command_list, Ergebnis mit doc_render_preview prüfen, mit doc_save oder doc_export (png, jpg, webp, tif, psd) sichern. Lange Filter laufen als Job (jobs_list). Dateien nur unter /share/artcraft/work. Öffnet keine PDFs, dafür PdfCraft.
```

Filterliste: `!control_call, !ui_inspect, !ui_menu_invoke, !ui_pointer, !ui_screenshot, !ui_set`

### PdfCraft (`craft-pdf`, Port 9083)

```
PdfCraft: PDFs öffnen, lesen, durchsuchen, bearbeiten, zusammenführen und aufteilen. Text mit text_extract und text_find, Seiten mit page_render ansehen, Dateien mit doc_combine (auch Bilder) und doc_split. Über 160 weitere Funktionen (Formulare, Kommentare, Seiten drehen, schwärzen, komprimieren …) mit tool_search finden und mit tool_call ausführen. Dateien nur unter /share/artcraft/work.
```

### Dateien (`craft-files`, Port 9084)

```
Arbeitsordner der ArtCraft-Apps: files_list zeigt Dateien, file_get liefert eine Datei (max. 10 MB), file_put legt eine Datei ab (base64, überschreibt nur mit overwrite=true). Pfade relativ zum Arbeitsordner. Damit Ergebnisse der Apps abholen oder Eingabedateien für sie bereitstellen.
```

### CADCraft (`craft-cad`, Port 9085)

```
CADCraft: 2D-CAD wie AutoCAD. DXF und DWG öffnen oder neue Zeichnung anlegen, zeichnen über command_line (Eingaben wie an der AutoCAD-Befehlszeile) oder script, Inhalt mit inspect_drawing, query_entities und find_text lesen, mit render als PNG prüfen, mit save als DXF, DWG, SVG, PNG oder PDF sichern. Achtung: nicht auf den Arbeitsordner begrenzt.
```

### WordCraft (`craft-word`, Port 9086)

```
WordCraft: Textverarbeitung wie Word. Dokumente anlegen (leer, Brief, Lebenslauf, Bericht) oder öffnen (docx, doc, odt, rtf, md, html, txt), Text schreiben mit type_text, formatieren und einfügen über execute und list_commands, mit render_page prüfen, mit save_document als docx, pdf, odt, md oder html sichern. Dateien nur unter /share/artcraft/work.
```

Filterliste: `!screenshot, !click, !key, !ui_inspect`

### DeckCraft (`craft-deck`, Port 9087)

```
DeckCraft: Präsentationen wie PowerPoint. Neue Präsentation mit Theme anlegen oder pptx öffnen, Folien mit add_slide, Text mit add_text_box und set_text, Bilder, Tabellen und Diagramme einfügen, mit render_slide prüfen, als pptx speichern oder als pdf und png exportieren. Alles Weitere über run_command und list_commands. Dateien nur unter /share/artcraft/work.
```

Filterliste: `!pointer, !select_tool, !key, !screenshot, !call_app`

### GridCraft (`craft-grid`, Port 9088)

```
GridCraft: Tabellenkalkulation wie Excel. Arbeitsmappen öffnen (xlsx, xls, ods, csv) oder neu anlegen, Werte mit read_range und write_range, Formeln mit set_cell, Formeln testen mit evaluate_formula, formatieren, sortieren, filtern, Tabellen und Diagramme anlegen, mit save_workbook sichern (xlsx, csv). Weitere Befehle über execute_command. Achtung: nicht auf den Arbeitsordner begrenzt.
```

Filterliste: `!screenshot`

### FigCraft (`craft-fig`, Port 9089)

```
FigCraft: Interface-Design wie Figma. Dokumente öffnen (figcraft, fig, sketch) oder Ebenen mit create_node anlegen und mit set_properties gestalten, Struktur mit inspect_document lesen, Entwurf mit screenshot ansehen, mit export als png, svg, jpg oder pdf ausgeben, mit save_file sichern. Weitere Befehle über run_command. Dateien nur unter /share/artcraft/work.
```

Filterliste: `!pointer, !key, !inspect_ui, !wait_for_changes`

### Craft Anything (`craft-anything`, Port 9090)

```
Craft Anything: Reverse Engineering und Nachbau von Programmen und Dateien mit lückenloser Beweisführung. Ziel öffnen, Brief und Plan schreiben, Hypothesen und Befunde mit Belegen festhalten, offene Fragen als Unknowns führen, Bericht erzeugen. Zusätzliche Werkzeuge (native code, Android, Web, Electron) mit list_toolsets und enable_toolset zuschalten. Achtung: nicht auf den Arbeitsordner begrenzt.
```

Filterliste: `!core_person_ask, !core_action_approve`. Die Tools `assets_image_generate` und
`assets_model_generate` brauchen einen fal.ai-Schlüssel, ohne ihn ebenfalls ausblenden.

## Unterstützte Geräte

aarch64 (z. B. Raspberry Pi 4 und 5) und amd64. Die Apps brauchen glibc, deshalb basiert das Image
auf Debian und nicht auf Alpine.

## Hinweis

Inoffizielles Projekt, nicht mit storytold oder sigbit verbunden. Die Apps selbst stehen unter
ihren eigenen Lizenzen, siehe deren Repositories.
