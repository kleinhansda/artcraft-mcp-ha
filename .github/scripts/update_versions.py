#!/usr/bin/env python3
"""Prüft die neuesten Releases von VectorCraft, PhotoCraft, PdfCraft und mcp-auth-proxy.

Gibt es neue Versionen, werden die ARG-Zeilen im Dockerfile angepasst, die Add-on-Version
in config.yaml erhöht und ein Eintrag in CHANGELOG.md ergänzt. Ein Release wird nur
übernommen, wenn es Linux-Pakete für aarch64 und x86_64 enthält.

Schreibt "changed=true|false" und "summary=..." nach $GITHUB_OUTPUT (falls gesetzt).
Ohne Netzwerkzugriff auf andere Seiten als api.github.com und github.com.
"""
from __future__ import annotations

import datetime as dt
import hashlib
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADDON = ROOT / "artcraft_mcp"
DOCKERFILE = ADDON / "Dockerfile"
CONFIG = ADDON / "config.yaml"
CHANGELOG = ADDON / "CHANGELOG.md"

APPS = [
    # (Repo, ARG-Name, Paketname, Anzeigename)
    ("storytold/vectorcraft", "VECTORCRAFT_VERSION", "vectorcraft", "VectorCraft"),
    ("storytold/photocraft", "PHOTOCRAFT_VERSION", "photocraft", "PhotoCraft"),
    ("storytold/pdfcraft", "PDFCRAFT_VERSION", "pdfcraft-cli", "PdfCraft"),
]
PROXY_REPO = "sigbit/mcp-auth-proxy"
ARCHES = ("aarch64", "x86_64")
PROXY_ARCHES = {"PROXY_SHA256_ARM64": "linux-arm64", "PROXY_SHA256_AMD64": "linux-amd64"}


def http_get(url: str, api: bool = False) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "artcraft-mcp-ha-update"})
    token = os.environ.get("GITHUB_TOKEN")
    if api:
        req.add_header("Accept", "application/vnd.github+json")
        if token:
            req.add_header("Authorization", f"Bearer {token}")
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read()


def latest_release(repo: str) -> dict:
    return json.loads(http_get(f"https://api.github.com/repos/{repo}/releases/latest", api=True))


def read_arg(text: str, name: str) -> str:
    m = re.search(rf"^ARG {name}=(\S+)$", text, re.M)
    if not m:
        sys.exit(f"ARG {name} nicht im Dockerfile gefunden")
    return m.group(1)


def set_arg(text: str, name: str, value: str) -> str:
    return re.sub(rf"^ARG {name}=\S+$", f"ARG {name}={value}", text, count=1, flags=re.M)


def main() -> int:
    docker = DOCKERFILE.read_text()
    changes: list[str] = []

    for repo, arg, pkg, label in APPS:
        rel = latest_release(repo)
        new = rel["tag_name"].lstrip("v")
        old = read_arg(docker, arg)
        if new == old:
            continue
        sums = http_get(f"https://github.com/{repo}/releases/download/v{new}/SHA256SUMS.txt").decode()
        missing = [a for a in ARCHES if f"  {pkg}-{new}-linux-{a}.tar.gz" not in sums]
        if missing:
            print(f"{label} {new}: Pakete fehlen für {', '.join(missing)}, bleibt bei {old}")
            continue
        docker = set_arg(docker, arg, new)
        changes.append(f"{label} {old} → {new}")

    rel = latest_release(PROXY_REPO)
    new = rel["tag_name"].lstrip("v")
    old = read_arg(docker, "PROXY_VERSION")
    if new != old:
        assets = {a["name"]: a for a in rel.get("assets", [])}
        digests = {}
        for arg, suffix in PROXY_ARCHES.items():
            asset = assets.get(f"mcp-auth-proxy-{suffix}")
            if not asset:
                digests = {}
                print(f"mcp-auth-proxy {new}: Datei für {suffix} fehlt, bleibt bei {old}")
                break
            digest = (asset.get("digest") or "").removeprefix("sha256:")
            if not re.fullmatch(r"[0-9a-f]{64}", digest):
                digest = hashlib.sha256(http_get(asset["browser_download_url"])).hexdigest()
            digests[arg] = digest
        if digests:
            docker = set_arg(docker, "PROXY_VERSION", new)
            for arg, digest in digests.items():
                docker = set_arg(docker, arg, digest)
            changes.append(f"mcp-auth-proxy {old} → {new}")

    out = os.environ.get("GITHUB_OUTPUT")
    if not changes:
        print("Keine neuen Versionen.")
        if out:
            with open(out, "a") as f:
                f.write("changed=false\n")
        return 0

    config = CONFIG.read_text()
    m = re.search(r'^version: "(\d+)\.(\d+)\.(\d+)"$', config, re.M)
    if not m:
        sys.exit("version in config.yaml nicht gefunden")
    major, minor, patch = map(int, m.groups())
    version = f"{major}.{minor}.{patch + 1}"
    config = config.replace(m.group(0), f'version: "{version}"', 1)

    today = dt.date.today().isoformat()
    entry = f"## {version} ({today})\n\n" + "".join(f"- {c}\n" for c in changes) + "\n"
    log = CHANGELOG.read_text()
    head, sep, rest = log.partition("\n## ")
    log = f"{head.rstrip()}\n\n{entry}" + (f"## {rest}" if sep else "")

    DOCKERFILE.write_text(docker)
    CONFIG.write_text(config)
    CHANGELOG.write_text(log)

    summary = f"Version {version}: " + ", ".join(changes)
    print(summary)
    if out:
        with open(out, "a") as f:
            f.write(f"changed=true\nversion={version}\nsummary={summary}\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
