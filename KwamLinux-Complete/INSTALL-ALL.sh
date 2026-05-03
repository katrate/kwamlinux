#!/bin/bash
# ============================================================
#  KWAMLINUX - Master Installer (All Phases)
#  Run this after booting into the Kwamlinux ISO
#  Installs everything: base → theme → kwamlinux → welcome app
# ============================================================

set -e
R='\033[0;31m'; G='\033[0;32m'; Y='\033[1;33m'
C='\033[0;36m'; P='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${G}[✔]${NC} $1"; }
section() { echo -e "\n${BOLD}${P}════════════════════════════════${NC}"; echo -e "${BOLD}${C}  $1${NC}"; echo -e "${BOLD}${P}════════════════════════════════${NC}"; }
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

clear
echo -e "${P}"
echo "  ██╗  ██╗██╗    ██╗ █████╗ ███╗   ███╗"
echo "  ██║ ██╔╝██║    ██║██╔══██╗████╗ ████║"
echo "  █████╔╝ ██║ █╗ ██║███████║██╔████╔██║"
echo "  ██╔═██╗ ██║███╗██║██╔══██║██║╚██╔╝██║"
echo "  ██║  ██╗╚███╔███╔╝██║  ██║██║ ╚═╝ ██║"
echo "  ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝"
echo -e "${C}         Complete Installer — All Phases${NC}"
echo ""

section "Phase 1 — Base System & Disk Install"
bash "$DIR/scripts/install.sh"

section "Phase 2 — Theme, Dock & Animations"
bash "$DIR/install-theme.sh"

section "Phase 3 — kwamlinux Package Manager"
bash "$DIR/install.sh"

section "Phase 4 — Welcome App & Wallpapers"
bash "$DIR/wallpapers/src/generate.py" 2>/dev/null || python3 "$DIR/wallpapers/src/generate.py"
bash "$DIR/wallpapers/install-wallpapers.sh"

echo ""
echo -e "${G}════════════════════════════════════${NC}"
echo -e "${G}  Kwamlinux is fully installed! 🚀  ${NC}"
echo -e "${G}════════════════════════════════════${NC}"
echo ""
echo -e "${C}Reboot to start using Kwamlinux:${NC}"
echo "  reboot"
