# ArtCraft MCP für Home Assistant

Home-Assistant-Add-on (App), das VectorCraft, PhotoCraft und PdfCraft von
[storytold](https://github.com/storytold) als Remote-MCP-Server für Claude bereitstellt.
Login über einen OIDC-Anbieter (z. B. Pocket ID) mit
[mcp-auth-proxy](https://github.com/sigbit/mcp-auth-proxy), Zugang z. B. über das
Cloudflared-Add-on.

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
| `artcraft_mcp/rootfs/run.sh` | Startet je App einen Proxy, startet abgestürzte Dienste einzeln neu |
| `artcraft_mcp/rootfs/usr/local/lib/artcraft/apps.sh` | Startbefehle und Ports der Apps |
| `.github/workflows/update.yml` | Prüft täglich neue Releases, testet und erhöht dann die Version |

## Unterstützte Geräte

aarch64 (z. B. Raspberry Pi 4 und 5) und amd64. Die Apps brauchen glibc, deshalb basiert das Image
auf Debian und nicht auf Alpine.

## Hinweis

Inoffizielles Projekt, nicht mit storytold oder sigbit verbunden. Die Apps selbst stehen unter
ihren eigenen Lizenzen, siehe deren Repositories.
