#!/bin/bash
# ============================================================
#  KWAM LINUX - Phase 2 Theme Installer
#  Installs the full Kwam premium desktop experience
# ============================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}══════ $1 ══════${NC}"; }

THEME_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_dependencies() {
    section "Installing Theme Dependencies"
    sudo pacman -S --noconfirm --needed \
        latte-dock \
        kvantum \
        papirus-icon-theme \
        bibata-cursor-theme \
        plasma-desktop \
        kdecoration \
        qt5-graphicaleffects \
        zsh-autosuggestions \
        zsh-syntax-highlighting \
        noto-fonts \
        noto-fonts-emoji \
        ttf-jetbrains-mono \
        ttf-fira-code \
        xdg-desktop-portal-kde || warn "Some packages failed — continuing"
    log "Dependencies installed"
}

install_color_scheme() {
    section "Installing Colour Scheme"
    mkdir -p ~/.local/share/color-schemes
    cp "$THEME_DIR/theme/colors/KwamDark.colors" ~/.local/share/color-schemes/
    plasma-apply-colorscheme KwamDark 2>/dev/null || \
        kwriteconfig5 --file kdeglobals --group General --key ColorScheme KwamDark
    log "Colour scheme installed"
}

install_kvantum_theme() {
    section "Installing Kvantum (Glassmorphism)"
    mkdir -p ~/.config/Kvantum
    cp -r "$THEME_DIR/kvantum/KwamDark" ~/.config/Kvantum/
    kvantummanager --set KwamDark 2>/dev/null || \
        kwriteconfig5 --file ~/.config/Kvantum/kvantum.kvconfig --group General --key theme KwamDark
    kwriteconfig5 --file kdeglobals --group General --key widgetStyle kvantum-dark
    log "Kvantum theme installed"
}

install_look_and_feel() {
    section "Installing Look & Feel"
    mkdir -p ~/.local/share/plasma/look-and-feel
    cp -r "$THEME_DIR/theme/plasma/look-and-feel/com.kwamlinux.desktop" \
        ~/.local/share/plasma/look-and-feel/
    plasma-apply-lookandfeel com.kwamlinux.desktop 2>/dev/null || \
        warn "Could not auto-apply look and feel — apply manually in System Settings"
    log "Look & Feel installed"
}

install_icons_cursors() {
    section "Installing Icons & Cursors"
    kwriteconfig5 --file kdeglobals --group Icons --key Theme Papirus-Dark
    kwriteconfig5 --file kcminputrc --group Mouse --key cursorTheme Bibata-Modern-Amber
    /usr/lib/plasma-changeicons Papirus-Dark 2>/dev/null || true
    log "Icons & Cursors configured"
}

install_latte_dock() {
    section "Installing Latte Dock (macOS-style)"
    mkdir -p ~/.config/latte
    cp "$THEME_DIR/latte/KwamDock.latte" ~/.config/latte/
    # Enable latte to autostart
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/latte-dock.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Latte Dock
Exec=latte-dock --replace
Icon=latte-dock
X-GNOME-Autostart-enabled=true
EOF
    log "Latte Dock installed"
}

apply_fonts() {
    section "Applying Fonts"
    kwriteconfig5 --file kdeglobals --group General \
        --key font "JetBrains Mono,11,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General \
        --key fixed "JetBrains Mono,11,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General \
        --key smallestReadableFont "JetBrains Mono,9,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General \
        --key toolBarFont "Fira Code,10,-1,5,50,0,0,0,0,0"
    kwriteconfig5 --file kdeglobals --group General \
        --key menuFont "Fira Code,10,-1,5,50,0,0,0,0,0"
    log "Fonts applied"
}

apply_animations() {
    section "Applying Premium Animations"
    bash "$THEME_DIR/scripts/apply-animations.sh"
    log "Animations applied"
}

configure_top_bar() {
    section "Configuring Top Bar"
    # Set panel height to 28px (macOS menubar height)
    kwriteconfig5 --file plasmashellrc --group PlasmaViews \
        --key panelHeight 28

    # Transparent panel
    kwriteconfig5 --file plasmarc --group Theme \
        --key name KwamDark
    log "Top bar configured"
}

apply_gtk_theme() {
    section "Applying GTK Theme (for non-Qt apps)"
    mkdir -p ~/.config/gtk-3.0 ~/.config/gtk-4.0

    cat > ~/.config/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Amber
gtk-font-name=JetBrains Mono 11
gtk-application-prefer-dark-theme=true
gtk-button-images=false
gtk-decoration-layout=close,minimize,maximize:
gtk-enable-animations=true
gtk-primary-button-warps-slider=false
EOF

    cat > ~/.config/gtk-4.0/settings.ini << 'EOF'
[Settings]
gtk-icon-theme-name=Papirus-Dark
gtk-cursor-theme-name=Bibata-Modern-Amber
gtk-font-name=JetBrains Mono 11
gtk-application-prefer-dark-theme=true
gtk-decoration-layout=close,minimize,maximize:
gtk-enable-animations=true
EOF
    log "GTK theme configured"
}

finish() {
    section "Theme Installation Complete!"
    echo ""
    log "Kwm Dark theme is now installed!"
    echo ""
    echo -e "${CYAN}Applied:${NC}"
    echo "  🎨 Colour scheme — Kwam Dark (purple accent)"
    echo "  🪟 Glassmorphism blur — via Kvantum"
    echo "  🎯 Latte Dock — macOS-style with magnification"
    echo "  📊 Top bar — transparent menubar style"
    echo "  ✨ Animations — Magic lamp, scale, wobbly"
    echo "  🖱️  Cursor — Bibata Modern Amber"
    echo "  📁 Icons — Papirus Dark"
    echo "  🔤 Fonts — JetBrains Mono"
    echo ""
    echo -e "${YELLOW}Log out and back in to see all changes.${NC}"
}

# ─── MAIN ───────────────────────────────────────────────────
install_dependencies
install_color_scheme
install_kvantum_theme
install_look_and_feel
install_icons_cursors
install_latte_dock
apply_fonts
apply_animations
configure_top_bar
apply_gtk_theme
finish
