#!/bin/bash
# ============================================================
#  KWAM LINUX - ISO Build Script
#  Builds a bootable Kwam Linux ISO using archiso
# ============================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

DISTRO_NAME="Kwam Linux"
VERSION="1.0.0"
BUILD_DIR="/tmp/kwam-build"
OUT_DIR="$(pwd)/output"
PROFILE_DIR="$(pwd)"

banner() {
    echo -e "${PURPLE}"
    echo "  ██╗  ██╗██╗    ██╗ █████╗ ███╗   ███╗"
    echo "  ██║ ██╔╝██║    ██║██╔══██╗████╗ ████║"
    echo "  █████╔╝ ██║ █╗ ██║███████║██╔████╔██║"
    echo "  ██╔═██╗ ██║███╗██║██╔══██║██║╚██╔╝██║"
    echo "  ██║  ██╗╚███╔███╔╝██║  ██║██║ ╚═╝ ██║"
    echo "  ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝"
    echo -e "${CYAN}       Linux — Security. Style. Power.${NC}"
    echo ""
}

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }
section() { echo -e "\n${BOLD}${CYAN}══════ $1 ══════${NC}"; }

check_root() {
    [[ $EUID -ne 0 ]] && error "Run as root: sudo ./build.sh"
}

check_deps() {
    section "Checking Dependencies"
    for dep in archiso mkarchiso curl git; do
        if command -v $dep &>/dev/null; then
            log "$dep found"
        else
            warn "$dep not found — installing..."
            pacman -S --noconfirm $dep || error "Failed to install $dep"
        fi
    done
}

setup_build_dir() {
    section "Setting Up Build Environment"
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR" "$OUT_DIR"
    cp -r "$PROFILE_DIR"/* "$BUILD_DIR/"
    log "Build directory ready: $BUILD_DIR"
}

configure_pacman() {
    section "Configuring Pacman"
    cat > "$BUILD_DIR/config/pacman.conf" << 'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
ParallelDownloads = 10
Color
ILoveCandy

SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

# Kwam Official Repo (future)
# [kwam]
# SigLevel = Optional TrustAll
# Server = https://repo.kwamlinux.org/$arch
EOF
    log "Pacman configured"
}

apply_customizations() {
    section "Applying Kwam Customizations"

    # Set hostname
    echo "kwamlinux" > "$BUILD_DIR/airootfs/etc/hostname"

    # Set locale
    mkdir -p "$BUILD_DIR/airootfs/etc"
    cat > "$BUILD_DIR/airootfs/etc/locale.conf" << 'EOF'
LANG=en_US.UTF-8
LC_ALL=en_US.UTF-8
EOF

    # Hosts file
    cat > "$BUILD_DIR/airootfs/etc/hosts" << 'EOF'
127.0.0.1   localhost
::1         localhost
127.0.1.1   kwamlinux.localdomain kwamlinux
EOF

    # Custom MOTD
    mkdir -p "$BUILD_DIR/airootfs/etc"
    cat > "$BUILD_DIR/airootfs/etc/motd" << 'EOF'

  Welcome to Kwam Linux — Security. Style. Power.
  Docs:    https://kwamlinux.org/docs
  Support: https://kwamlinux.org/support

EOF

    # ZSH as default shell with Oh-My-Zsh style config
    mkdir -p "$BUILD_DIR/airootfs/etc/skel"
    cat > "$BUILD_DIR/airootfs/etc/skel/.zshrc" << 'EOF'
# Kwam Linux - Default ZSH Config
export DISTRO="Kwam Linux"
export PATH="$HOME/.local/bin:$PATH"

# Prompt
autoload -U colors && colors
PS1="%{$fg[magenta]%}[%{$fg[cyan]%}%n%{$fg[white]%}@%{$fg[blue]%}%m %{$fg[yellow]%}%~%{$fg[magenta]%}]%{$reset_color%}$ "

# Aliases
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias grep='grep --color=auto'
alias update='sudo pacman -Syu'
alias install='sudo pacman -S'
alias search='pacman -Ss'
alias remove='sudo pacman -Rs'
alias came-tools='ls /usr/share/kwamtools/'
alias neofetch='neofetch'

# Security aliases
alias scan='nmap -sV'
alias myip='curl ifconfig.me'
alias ports='netstat -tulnp'
alias fw-status='sudo ufw status verbose'

# History
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Auto-suggestions & syntax highlighting (if installed)
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Neofetch on terminal open
neofetch
EOF

    log "Customizations applied"
}

apply_security_config() {
    section "Hardening Security"

    mkdir -p "$BUILD_DIR/airootfs/etc/ufw"

    # UFW default rules
    cat > "$BUILD_DIR/airootfs/etc/ufw/ufw.conf" << 'EOF'
ENABLED=yes
LOGLEVEL=low
EOF

    # SSH hardening
    mkdir -p "$BUILD_DIR/airootfs/etc/ssh"
    cat > "$BUILD_DIR/airootfs/etc/ssh/sshd_config" << 'EOF'
Port 22
PermitRootLogin no
PasswordAuthentication yes
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
LoginGraceTime 20
AllowAgentForwarding no
AllowTcpForwarding no
EOF

    log "Security hardening applied"
}

setup_desktop() {
    section "Setting Up KDE Plasma (Premium UI)"

    mkdir -p "$BUILD_DIR/airootfs/etc/sddm.conf.d"
    cat > "$BUILD_DIR/airootfs/etc/sddm.conf.d/came.conf" << 'EOF'
[Theme]
Current=breeze

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Autologin]
Relogin=false
EOF

    # Enable services
    mkdir -p "$BUILD_DIR/airootfs/etc/systemd/system/multi-user.target.wants"
    mkdir -p "$BUILD_DIR/airootfs/etc/systemd/system/graphical.target.wants"

    log "Desktop environment configured"
}

build_iso() {
    section "Building Kwam Linux ISO"
    log "This may take 20-40 minutes depending on your internet speed..."

    mkarchiso -v -w "$BUILD_DIR/work" -o "$OUT_DIR" "$BUILD_DIR" \
        || error "ISO build failed. Check logs above."

    ISO_FILE=$(ls "$OUT_DIR"/*.iso 2>/dev/null | head -1)
    if [[ -f "$ISO_FILE" ]]; then
        SIZE=$(du -sh "$ISO_FILE" | cut -f1)
        log "ISO built successfully!"
        log "Location: $ISO_FILE"
        log "Size: $SIZE"
    else
        error "ISO file not found after build"
    fi
}

print_next_steps() {
    section "What's Next"
    echo -e "${CYAN}Test in QEMU:${NC}"
    echo "  qemu-system-x86_64 -m 4G -cdrom output/kwamlinux-*.iso -boot d"
    echo ""
    echo -e "${CYAN}Flash to USB:${NC}"
    echo "  sudo dd if=output/kwamlinux-*.iso of=/dev/sdX bs=4M status=progress"
    echo ""
    echo -e "${GREEN}Kwam Linux is ready! 🚀${NC}"
}

# ─── MAIN ───────────────────────────────────────────────────
banner
check_root
check_deps
setup_build_dir
configure_pacman
apply_customizations
apply_security_config
setup_desktop
build_iso
print_next_steps
