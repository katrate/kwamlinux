#!/bin/bash
# ============================================================
#  KWAMLINUX - Phase 4 Installer
#  Installs welcome app + wallpapers
# ============================================================

set -e
G='\033[0;32m'; C='\033[0;36m'; P='\033[0;35m'; NC='\033[0m'; BOLD='\033[1m'
log()     { echo -e "${G}[✔]${NC} $1"; }
section() { echo -e "\n${BOLD}${C}══════ $1 ══════${NC}"; }

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

section "Installing Welcome App"
if ! command -v node &>/dev/null; then
    sudo pacman -S --noconfirm nodejs npm
fi
cd "$DIR/welcome-app"
npm install --silent
sudo mkdir -p /usr/lib/kwamlinux/welcome
sudo cp -r src/ assets/ /usr/lib/kwamlinux/welcome/ 2>/dev/null || true
sudo install -Dm644 kwamlinux-welcome.desktop /usr/share/applications/kwamlinux-welcome.desktop
sudo install -Dm644 kwamlinux-welcome.desktop /etc/xdg/autostart/kwamlinux-welcome.desktop
log "Welcome app installed"

section "Installing Wallpapers"
cd "$DIR/wallpapers"
python3 src/generate.py
bash output/../install-wallpapers.sh
log "Wallpapers installed"

section "Phase 4 Complete!"
log "Welcome app will launch on next login"
log "3 wallpapers installed to /usr/share/wallpapers/kwamlinux"
echo ""
echo -e "${P}Preview welcome app:${NC}"
echo "  electron /usr/lib/kwamlinux/welcome/src/main.js"
