# ArtCraft MCP für Home Assistant – umgezogen

**Dieses Repository wird nicht mehr gepflegt.** ArtCraft MCP liegt ab Version 1.4.0 wieder in
**[kleinhansda/ha-mcp-addons](https://github.com/kleinhansda/ha-mcp-addons)**
([`artcraft_mcp`](https://github.com/kleinhansda/ha-mcp-addons/tree/main/artcraft_mcp)), zusammen mit
Foto, GitHub und Netlify MCP, Open WebUI und Open Terminal. Dort ist es weiter gepflegt, mit
mitgelieferten Schriften für PdfCraft (Option `fonts_to_work`).

Die App hier (1.3.0) bekommt keine Updates mehr. Sie bleibt nur für den Umzug installierbar.

## Umzug

1. In Home Assistant das Repository `https://github.com/kleinhansda/ha-mcp-addons` hinzufügen und
   **ArtCraft MCP** daraus installieren. Optionen übernehmen (URLs, OIDC-Client, `work_dir`,
   `internal_apps`).
2. Diese App stoppen, die neue starten. Der Arbeitsordner unter `/share` bleibt, wie er ist.
3. Im Cloudflare-Tunnel die Dienst-URLs von `http://d292e89e-artcraft-mcp:<port>` auf
   `http://be60cb4b-artcraft-mcp:<port>` umstellen, in Open WebUI die internen URLs ebenso.
4. Die Connectoren in Claude einmal neu verbinden (die Proxy-Daten werden nicht übernommen).
5. Diese App deinstallieren und dieses Repository in Home Assistant entfernen.

Ausführlich: [DOCS, „Umzug aus artcraft-mcp-ha“](https://github.com/kleinhansda/ha-mcp-addons/blob/main/artcraft_mcp/DOCS.md#umzug-aus-artcraft-mcp-ha).
Hintergrund, Notizen und Beschreibungen für MCP-Verbindungen:
[docs/ARTCRAFT.md](https://github.com/kleinhansda/ha-mcp-addons/blob/main/docs/ARTCRAFT.md).
