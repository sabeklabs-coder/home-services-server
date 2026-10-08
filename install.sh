#!/usr/bin/env bash
# ==================================================================
#  HSS — Home Services Server · installation par URL
# ------------------------------------------------------------------
#  curl -fsSL https://raw.githubusercontent.com/sabeklabs-coder/\
#  home-services-server/main/install.sh | bash
#
#  Ce script ne fait que quatre choses, et rien d'autre :
#
#    1. reconnaitre l'architecture de la machine ;
#    2. telecharger l'installateur de la derniere version publiee ;
#    3. VERIFIER son empreinte SHA-256 avant de l'executer ;
#    4. le lancer.
#
#  Il n'ecrit rien hors de son dossier temporaire, et n'utilise sudo
#  nulle part. C'est l'installateur lui-meme qui demandera les droits,
#  une fois que vous l'aurez vu arriver.
#
#  Licence : usage personnel. Modification et redistribution
#  interdites. Voir LICENSE sur le depot.
# ==================================================================
set -uo pipefail

DEPOT="${HSS_REPO:-sabeklabs-coder/home-services-server}"
API="https://api.github.com/repos/$DEPOT/releases/latest"

if [ -t 2 ]; then
    R=$'\033[31m'; V=$'\033[32m'; J=$'\033[33m'; C=$'\033[36m'
    G=$'\033[1m'; D=$'\033[2m'; Z=$'\033[0m'
else
    R=''; V=''; J=''; C=''; G=''; D=''; Z=''
fi

info() { printf '  %s•%s %s\n' "$C" "$Z" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$V" "$Z" "$*"; }
avert(){ printf '  %s!%s %s\n' "$J" "$Z" "$*"; }
mort() { printf '\n  %s✖ %s%s\n\n' "$R" "$*" "$Z" >&2; exit 1; }

printf '\n%s  HSS — Home Services Server%s\n' "$G" "$Z"
printf '%s  installation depuis %s%s\n\n' "$D" "$DEPOT" "$Z"

# ── 1. L'architecture ──────────────────────────────────────────────
# On la detecte pour le DIRE, pas pour choisir un fichier : depuis le
# 08/10/2026 il n'y a qu'un installateur, et il est UNIVERSEL. Il porte
# gum et les paquets hors-ligne pour les deux architectures, et choisit
# les bons une fois sur la machine (scripts/lib/ui.sh l. 149 et
# scripts/hss-deploy.sh l. 1323).
#
# Le controle reste utile : il arrete tout de suite sur un materiel que
# HSS ne gere pas, plutot qu'apres avoir telecharge 182 Mo pour rien.
case "$(uname -m)" in
    x86_64|amd64|aarch64|arm64) : ;;
    *) mort "Architecture non prise en charge : $(uname -m)
     HSS fonctionne sur x86_64 (amd64) et aarch64 (arm64)." ;;
esac
ok "architecture : $(uname -m) — l'installateur est universel"

# ── 2. Les outils ─────────────────────────────────────────────────
for o in curl tar; do
    command -v "$o" >/dev/null 2>&1 || mort "« $o » est introuvable. Installez-le, puis relancez."
done
if command -v sha256sum >/dev/null 2>&1; then
    EMPREINTE() { sha256sum "$1" | cut -d' ' -f1; }
elif command -v shasum >/dev/null 2>&1; then
    EMPREINTE() { shasum -a 256 "$1" | cut -d' ' -f1; }
else
    mort "Ni sha256sum ni shasum : impossible de verifier ce qui va etre telecharge.
     Le script refuse d'executer un fichier qu'il n'a pas pu controler."
fi

# ── 3. La derniere version publiee ────────────────────────────────
info "recherche de la derniere version…"
REPONSE="$(curl -fsSL -H 'Accept: application/vnd.github+json' "$API" 2>/dev/null)" || REPONSE=''

if [ -z "$REPONSE" ]; then
    mort "Aucune version publiee sur $DEPOT — ou GitHub est injoignable.

     Le depot est en place mais le premier .run public n'est pas
     encore publie. Suivez l'avancement sur :
       https://github.com/$DEPOT"
fi

if command -v python3 >/dev/null 2>&1; then
    # Un JSON ne se lit pas a la grep : une URL d'actif peut contenir
    # n'importe quoi, et l'ordre des cles n'est pas garanti.
    lire() { printf '%s' "$REPONSE" | python3 -c '
import json, sys
d = json.load(sys.stdin)
quoi = sys.argv[1]
if quoi == "tag":
    print(d.get("tag_name", ""))
else:
    suffixe = "-public.run" if quoi == "run" else quoi
    for a in d.get("assets", []):
        n = a.get("name", "")
        if (quoi == "run" and n.endswith(suffixe)) or (quoi != "run" and n == suffixe):
            print(a.get("browser_download_url", "")); break
' "$1" 2>/dev/null; }
else
    lire() {
        case "$1" in
          tag) printf '%s' "$REPONSE" | tr ',' '\n' | grep -m1 '"tag_name"' \
                 | sed 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/' ;;
          run) printf '%s' "$REPONSE" | tr ',' '\n' | grep -m1 -o \
                 "https://[^\"]*-public\.run" ;;
          *)   printf '%s' "$REPONSE" | tr ',' '\n' | grep -m1 -o \
                 "https://[^\"]*/$1" ;;
        esac
    }
fi

VERSION="$(lire tag)"
URL_RUN="$(lire run)"
URL_SUMS="$(lire SHA256SUMS)"

[ -n "$VERSION" ] || mort "Reponse de GitHub illisible. Reessayez dans un moment."
[ -n "$URL_RUN" ]  || mort "La version $VERSION ne publie aucun installateur.
     L'actif attendu se nomme « hss-<version>-public.run ».

     Il est UNIVERSEL : il porte les deux architectures, et choisit la
     bonne a l'installation. Il n'y a donc pas de fichier par
     architecture a chercher."
ok "version : $VERSION"

# ── 4. Telechargement dans un dossier temporaire ──────────────────
TMP="$(mktemp -d "${TMPDIR:-/tmp}/hss-install.XXXXXX")" || mort "mktemp a echoue"
trap 'rm -rf "$TMP"' EXIT INT TERM
RUN="$TMP/$(basename "$URL_RUN")"

info "telechargement de $(basename "$URL_RUN")…"
curl -fL --progress-bar -o "$RUN" "$URL_RUN" || mort "Telechargement interrompu."
[ -s "$RUN" ] || mort "Le fichier telecharge est vide."
ok "telecharge : $(du -h "$RUN" | cut -f1)"

# ── 5. L'empreinte, avant tout ────────────────────────────────────
# HSS_SHA256 permet d'imposer une empreinte obtenue AILLEURS que sur
# cette page de version. C'est le seul controle qui protege contre un
# depot compromis : SHA256SUMS et le .run viennent du meme endroit, et
# qui peut remplacer l'un peut remplacer l'autre. La verification
# contre SHA256SUMS, elle, attrape ce qui arrive vraiment souvent — un
# telechargement tronque, un miroir en retard, un disque qui ment.
CALCULE="$(EMPREINTE "$RUN")"
ATTENDU="${HSS_SHA256:-}"

if [ -z "$ATTENDU" ] && [ -n "$URL_SUMS" ]; then
    if curl -fsSL -o "$TMP/SHA256SUMS" "$URL_SUMS" 2>/dev/null; then
        ATTENDU="$(grep -F " $(basename "$RUN")" "$TMP/SHA256SUMS" 2>/dev/null \
                   | head -1 | cut -d' ' -f1)"
    fi
fi

if [ -z "$ATTENDU" ]; then
    avert "aucune empreinte de reference publiee avec cette version."
    avert "empreinte du fichier telecharge :"
    printf '      %s%s%s\n' "$G" "$CALCULE" "$Z"
    mort "Rien ne sera execute sans empreinte a comparer.

     Comparez la valeur ci-dessus avec celle annoncee sur la page de
     la version, puis relancez en l'imposant :
       HSS_SHA256=<empreinte> bash install.sh"
fi

if [ "$CALCULE" != "$ATTENDU" ]; then
    printf '\n      attendu : %s\n      obtenu  : %s\n' "$ATTENDU" "$CALCULE" >&2
    mort "EMPREINTE INVALIDE — le fichier n'est pas celui qui a ete publie.
     Rien n'a ete execute. Ne reessayez pas sans comprendre pourquoi."
fi
ok "empreinte SHA-256 verifiee"

# ── 6. Lancement ──────────────────────────────────────────────────
chmod +x "$RUN"

if [ "$(id -u)" = "0" ]; then
    avert "vous etes root. HSS s'installe depuis un compte ordinaire"
    avert "muni de sudo : c'est ce compte qui possedera le projet."
fi

# L'installateur POSE DES QUESTIONS. Lance depuis « curl | bash », son
# entree standard est le script lui-meme, et toute question recevrait
# du code source en reponse. On lui rebranche donc le terminal — et
# s'il n'y en a pas, on s'arrete en disant quoi taper.
if [ -r /dev/tty ]; then
    printf '\n%s  L'"'"'installateur prend la main. Il demandera sudo.%s\n\n' "$D" "$Z"
    # Le .run est conserve : trap desarme, dossier temporaire garde.
    trap - EXIT INT TERM
    "$RUN" < /dev/tty
    code=$?
    rm -rf "$TMP"
    exit "$code"
fi

GARDE="${HOME:-/tmp}/$(basename "$RUN")"
cp "$RUN" "$GARDE" && chmod +x "$GARDE"
printf '\n'
avert "aucun terminal disponible — l'installateur pose des questions,"
avert "il ne peut pas tourner sans vous."
printf '\n  Il est pret ici :\n    %s%s%s\n\n  Lancez-le :\n    %s%s%s\n\n' \
    "$G" "$GARDE" "$Z" "$G" "$GARDE" "$Z"
exit 0
