#!/data/data/com.termux/files/usr/bin/bash
# WebMirror — Termux website backup/mirroring helper
# Intended for websites you own or are authorized to archive/test.
# Does NOT create credential-capture pages or phishing infrastructure.

set -u

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
RESET='\033[0m'

banner() {
  clear
  printf "${GREEN}"
  cat <<'EOF'
 __        __   _     __  __ _                   
 \ \      / /__| |__ |  \/  (_) _ __ ___  _ __
  \ \ /\ / / _ \ '_ \| |\/| | | '__/ _ \| '__|
   \ V  V /  __/ |_) | |  | | | | | (_) | |
    \_/\_/ \___|_.__/|_|  |_|_|_|  \___/|_|

              WEBMIRROR • TERMUX
EOF
  printf "${RESET}\n"
  echo -e "${YELLOW}For sites you own or are authorized to archive.${RESET}"
  echo
}

install_deps() {
  echo "[*] Installing required packages..."
  pkg update -y
  pkg install -y wget curl
  echo -e "${GREEN}[+] Ready.${RESET}"
}

validate_url() {
  local url="$1"
  case "$url" in
    http://*|https://*) return 0 ;;
    *) echo -e "${RED}[!] URL must start with http:// or https://${RESET}"; return 1 ;;
  esac
}

mirror_site() {
  local url="$1"
  local out="$2"

  validate_url "$url" || return
  mkdir -p "$out"

  echo -e "${CYAN}[*] Mirroring public web assets...${RESET}"
  echo "[*] Output: $out"
  echo "[!] This is an archive of publicly accessible content."
  echo

  wget \
    --mirror \
    --convert-links \
    --adjust-extension \
    --page-requisites \
    --no-parent \
    --directory-prefix="$out" \
    --timeout=15 \
    --tries=2 \
    "$url"

  echo
  echo -e "${GREEN}[+] Mirror finished.${RESET}"
  echo "[*] Open the generated HTML files locally to inspect the archive."
}

single_page() {
  local url="$1"
  local file="$2"

  validate_url "$url" || return

  echo "[*] Saving public page to: $file"
  curl -L --fail --max-time 30 "$url" -o "$file" &&
    echo -e "${GREEN}[+] Saved.${RESET}" ||
    echo -e "${RED}[!] Download failed.${RESET}"
}

show_help() {
  cat <<'EOF'

Usage:
  1) Install dependencies
  2) Mirror a website you own / can legally archive
  3) Download one public HTML page
  4) Exit

Notes:
  - This tool is for website backup, migration, development, and authorized testing.
  - It does not copy passwords, cookies, sessions, or authentication credentials.
  - Do not use a mirror to impersonate a real service or collect visitors' credentials.

EOF
}

main() {
  banner

  while true; do
    echo "1) Install dependencies"
    echo "2) Mirror a website"
    echo "3) Download one HTML page"
    echo "4) Help"
    echo "0) Exit"
    echo
    read -rp "Select: " choice

    case "$choice" in
      1)
        install_deps
        ;;
      2)
        read -rp "Website URL: " url
        read -rp "Output folder [webmirror]: " out
        [ -z "$out" ] && out="webmirror"
        mirror_site "$url" "$out"
        ;;
      3)
        read -rp "Page URL: " url
        read -rp "Output filename [index.html]: " file
        [ -z "$file" ] && file="index.html"
        single_page "$url" "$file"
        ;;
      4)
        show_help
        ;;
      0)
        echo "Bye."
        exit 0
        ;;
      *)
        echo -e "${RED}[!] Invalid option.${RESET}"
        ;;
    esac

    echo
    read -rp "Press Enter to continue..."
    banner
  done
}

main
