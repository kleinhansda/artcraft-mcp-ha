# ArtCraft MCP: VectorCraft, PhotoCraft, PdfCraft und CADCraft, WordCraft, DeckCraft,
# GridCraft, FigCraft, Craft Anything als MCP-Server über mcp-auth-proxy.
# Release-Binaries von GitHub, geprüft gegen SHA256. Versionen werden über
# .github/workflows/update.yml gepflegt.
FROM debian:bookworm-slim

ARG BUILD_ARCH
ARG BUILD_VERSION

# Alte Tools
ARG VECTORCRAFT_VERSION=0.20.0
ARG PHOTOCRAFT_VERSION=0.19.0
ARG PDFCRAFT_VERSION=0.17.0
# Neue Tools
ARG CADCRAFT_VERSION=0.16.0
ARG WORDCRAFT_VERSION=0.14.0
ARG DECKCRAFT_VERSION=0.14.1
ARG GRIDCRAFT_VERSION=0.15.0
ARG FIGCRAFT_VERSION=0.14.0
ARG CRAFT_ANYTHING_VERSION=0.3.0
# Proxy
ARG PROXY_VERSION=2.10.2
ARG PROXY_SHA256_ARM64=924c5335e5f684eb22c681cca1daff86d96fa35f644950cbd8f4c8f3e290bc3d
ARG PROXY_SHA256_AMD64=1c76b230fdb6c536a0912c059232cba2229acbcf1f02a11a5d0664781326bcd6

LABEL \
  io.hass.version="${BUILD_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}" \
  org.opencontainers.image.source="https://github.com/kleinhansda/artcraft-mcp-ha"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# SHA256 für die neuen Tools (linux-aarch64 / linux-x86_64)
# cadcraft
ARG CADCRAFT_SHA256_ARM64=33876da3091d66988cfac198a467b3e18e7bc91c0052e36416e886a3db1896db
ARG CADCRAFT_SHA256_AMD64=149820b3d0e1e729a2256e344523b9805871d39ee39c9e085f507707f73ccbd4
# wordcraft
ARG WORDCRAFT_SHA256_ARM64=a02e3ef3eab365aca36c5a6a0b8b00a9252562c90ab7da884b83ef701dfae8f0
ARG WORDCRAFT_SHA256_AMD64=3010da3d352d95256ec9a17a03966280a1d41ba09d0ebe569af23092d8b64987
# deckcraft
ARG DECKCRAFT_SHA256_ARM64=ea5659174fe800736fd6a9e697b106c4de962fe00946707bbf884c23e26ec81c
ARG DECKCRAFT_SHA256_AMD64=e86c7fa0ecb55f1a553ee425b93dcfdc806b7b3798f272b41f1d1ff74ac5c12a
# gridcraft
ARG GRIDCRAFT_SHA256_ARM64=90b2b21613546309bbed30365914ba9c20dd6f7d175ac7ded7e27bc68e65539a
ARG GRIDCRAFT_SHA256_AMD64=6810f8ce7394b5a7cdfaf39838257b6384dceb9f8325024d475db895ee59daaa
# figcraft
ARG FIGCRAFT_SHA256_ARM64=17849e8fee7fa6655e02ef071e27f7bdb7edd0019172cd2e8e3523204cab0535
ARG FIGCRAFT_SHA256_AMD64=0ea489ce299238af96106940cddb42091c3eba109c05fdf843b4e7f8eb970829
# craft-anything
ARG CRAFT_ANYTHING_SHA256_ARM64=4dc9c0dfaed3a79beb5f6b7fc5da5b3e6abce658c067f5429891e35f34562954
ARG CRAFT_ANYTHING_SHA256_AMD64=674ec59ffbdaefbd577917e07c9d464562043b275a3889ba4f60239a12f03d53

RUN set -eu; \
  apt-get update; \
  apt-get install -y --no-install-recommends ca-certificates curl jq python3; \
  case "$(uname -m)" in \
    aarch64) A=aarch64; P=arm64; PSUM="$PROXY_SHA256_ARM64" \
      CS="$CADCRAFT_SHA256_ARM64"; WS="$WORDCRAFT_SHA256_ARM64"; \
      DS="$DECKCRAFT_SHA256_ARM64"; GS="$GRIDCRAFT_SHA256_ARM64"; \
      FS="$FIGCRAFT_SHA256_ARM64"; AS="$CRAFT_ANYTHING_SHA256_ARM64" ;; \
    x86_64)  A=x86_64;  P=amd64; PSUM="$PROXY_SHA256_AMD64" \
      CS="$CADCRAFT_SHA256_AMD64"; WS="$WORDCRAFT_SHA256_AMD64"; \
      DS="$DECKCRAFT_SHA256_AMD64"; GS="$GRIDCRAFT_SHA256_AMD64"; \
      FS="$FIGCRAFT_SHA256_AMD64"; AS="$CRAFT_ANYTHING_SHA256_AMD64" ;; \
    *) echo "Nicht unterstützte Architektur: $(uname -m)" >&2; exit 1 ;; \
  esac; \
  cd /tmp; \
  # Download- und Install-Funktion: $1=repo, $2=version, $3=binary-name, $4=inner-path, $5=sha256
  dload() { repo=$1; v=$2; name=$3; inner=$4; sha=$5; \
    asset="$name-$v-linux-$A.tar.gz"; \
    base="https://github.com/storytold/$repo/releases/download/v$v"; \
    curl -fsSLO "$base/$asset"; \
    echo "$sha  $asset" | sha256sum -c -; \
    tar xzf "$asset" -C /usr/local/bin --no-same-owner \
      --strip-components="$(echo "$inner" | awk -F/ '{print NF}')" "${asset%.tar.gz}/$inner"; \
    echo "$repo $v" >> /usr/local/share/artcraft-versions; \
    rm -f "$asset"; }; \
  dload vectorcraft "$VECTORCRAFT_VERSION" vectorcraft  bin/vectorcraft-cli "$SHA_UNKNOWN"; \
  dload photocraft  "$PHOTOCRAFT_VERSION"  photocraft   bin/photocraft-cli "$SHA_UNKNOWN"; \
  dload pdfcraft    "$PDFCRAFT_VERSION"    pdfcraft-cli pdfcraft-cli "$SHA_UNKNOWN"; \
  dload cadcraft    "$CADCRAFT_VERSION"    cadcraft-cli bin/cadcraft "$CS"; \
  dload wordcraft   "$WORDCRAFT_VERSION"   wordcraft-cli bin/wordcraft-cli "$WS"; \
  dload deckcraft   "$DECKCRAFT_VERSION"   deckcraft-cli bin/deckcraft-cli "$DS"; \
  dload gridcraft   "$GRIDCRAFT_VERSION"   gridcraft-cli bin/gridcraft-cli "$GS"; \
  dload figcraft    "$FIGCRAFT_VERSION"    figcraft-cli bin/figcraft-cli "$FS"; \
  dload craft-anything "$CRAFT_ANYTHING_VERSION" craft-anything-cli bin/craft-anything-cli "$AS"; \
  curl -fsSL -o /usr/local/bin/mcp-auth-proxy \
    "https://github.com/sigbit/mcp-auth-proxy/releases/download/v$PROXY_VERSION/mcp-auth-proxy-linux-$P"; \
  echo "$PSUM  /usr/local/bin/mcp-auth-proxy" | sha256sum -c -; \
  chmod 755 /usr/local/bin/mcp-auth-proxy; \
  echo "mcp-auth-proxy $PROXY_VERSION" >> /usr/local/share/artcraft-versions; \
  apt-get purge -y --auto-remove curl; \
  rm -rf /var/lib/apt/lists/*

COPY rootfs /
RUN chmod 755 /run.sh /usr/local/bin/artcraft-selftest /usr/local/lib/artcraft/files_mcp.py

CMD ["/run.sh"]