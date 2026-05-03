#!/bin/bash
# ============================================================
#  KWAM LINUX - Interactive Installer
#  Installs Kwam Linux to disk (like Arch, but automated)
# ============================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; PURPLE='\033[0;35m'; BOLD='\033[1m'; NC='\033[0m'

log()     { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; exit 1; }
ask()     { echo -e "${CYAN}[?]${NC} $1"; }
section() { echo -e "\n${BOLD}${PURPLE}══════ $1 ══════${NC}"; }

banner() {
    clear
    echo -e "${PURPLE}"
    echo "  ██╗  ██╗██╗    ██╗ █████╗ ███╗   ███╗"
    echo "  ██║ ██╔╝██║    ██║██╔══██╗████╗ ████║"
    echo "  █████╔╝ ██║ █╗ ██║███████║██╔████╔██║"
    echo "  ██╔═██╗ ██║███╗██║██╔══██║██║╚██╔╝██║"
    echo "  ██║  ██╗╚███╔███╔╝██║  ██║██║ ╚═╝ ██║"
    echo "  ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝     ╚═╝"
    echo -e "${CYAN}         Interactive Installer v1.0${NC}"
    echo -e "${NC}"
}

# ─── GATHER INFO ────────────────────────────────────────────
gather_user_input() {
    section "Installation Setup"

    # Disk selection
    echo -e "\nAvailable disks:"
    lsblk -d -o NAME,SIZE,MODEL | grep -v "loop"
    echo ""
    ask "Enter target disk (e.g. /dev/sda or /dev/nvme0n1):"
    read -r DISK

    [[ ! -b "$DISK" ]] && error "Disk $DISK not found"

    ask "Username for your account:"
    read -r USERNAME
    [[ -z "$USERNAME" ]] && error "Username cannot be empty"

    ask "Hostname for this machine:"
    read -r HOSTNAME
    HOSTNAME=${HOSTNAME:-kwamlinux}

    ask "Timezone (e.g. America/New_York, Asia/Kolkata):"
    read -r TIMEZONE
    TIMEZONE=${TIMEZONE:-UTC}

    ask "Install type — (1) Full Desktop  (2) Minimal Security Only:"
    read -r INSTALL_TYPE

    echo ""
    warn "THIS WILL ERASE ALL DATA ON $DISK"
    ask "Are you sure? Type 'YES' to continue:"
    read -r CONFIRM
    [[ "$CONFIRM" != "YES" ]] && error "Installation cancelled."
}

# ─── PARTITION ──────────────────────────────────────────────
partition_disk() {
    section "Partitioning Disk: $DISK"

    # Detect if UEFI or BIOS
    if [[ -d /sys/firmware/efi ]]; then
        BOOT_MODE="UEFI"
        log "Boot mode: UEFI"

        parted -s "$DISK" mklabel gpt
        parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB
        parted -s "$DISK" set 1 esp on
        parted -s "$DISK" mkpart primary linux-swap 513MiB 4607MiB
        parted -s "$DISK" mkpart primary ext4 4607MiB 100%

        # Format
        if [[ "$DISK" == *"nvme"* ]]; then
            EFI_PART="${DISK}p1"
            SWAP_PART="${DISK}p2"
            ROOT_PART="${DISK}p3"
        else
            EFI_PART="${DISK}1"
            SWAP_PART="${DISK}2"
            ROOT_PART="${DISK}3"
        fi

        mkfs.fat -F32 "$EFI_PART"
        mkswap "$SWAP_PART"
        mkfs.ext4 -L kwamroot "$ROOT_PART"

        mount "$ROOT_PART" /mnt
        mkdir -p /mnt/boot/efi
        mount "$EFI_PART" /mnt/boot/efi
        swapon "$SWAP_PART"

    else
        BOOT_MODE="BIOS"
        log "Boot mode: BIOS/Legacy"

        parted -s "$DISK" mklabel msdos
        parted -s "$DISK" mkpart primary linux-swap 1MiB 4095MiB
        parted -s "$DISK" mkpart primary ext4 4095MiB 100%
        parted -s "$DISK" set 2 boot on

        SWAP_PART="${DISK}1"
        ROOT_PART="${DISK}2"

        mkswap "$SWAP_PART"
        mkfs.ext4 -L kwamroot "$ROOT_PART"

        mount "$ROOT_PART" /mnt
        swapon "$SWAP_PART"
    fi

    log "Partitioning complete"
}

# ─── INSTALL BASE ───────────────────────────────────────────
install_base() {
    section "Installing Came Base System"

    log "Updating mirrors..."
    reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

    log "Installing base packages..."
    pacstrap /mnt \
        base base-devel linux linux-firmware linux-headers \
        networkmanager grub efibootmgr sudo \
        zsh vim curl wget git neofetch btop \
        openssh ufw fail2ban

    log "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab

    log "Base system installed"
}

# ─── CONFIGURE SYSTEM ───────────────────────────────────────
configure_system() {
    section "Configuring Came Linux"

    arch-chroot /mnt /bin/bash << CHROOT_EOF

# Timezone
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "${HOSTNAME}" > /etc/hostname
cat >> /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF

# Root password
echo "Set ROOT password:"
passwd

# Create user
useradd -m -G wheel,audio,video,optical,storage -s /bin/zsh ${USERNAME}
echo "Set password for ${USERNAME}:"
passwd ${USERNAME}

# Sudo for wheel group
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

# Enable services
systemctl enable NetworkManager
systemctl enable sshd
systemctl enable ufw

# Bootloader
if [[ "${BOOT_MODE}" == "UEFI" ]]; then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=KWAM
else
    grub-install --target=i386-pc ${DISK}
fi

# Custom GRUB title
sed -i 's/GRUB_DISTRIBUTOR=.*/GRUB_DISTRIBUTOR="Kwam Linux"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Set OS release
cat > /etc/os-release << EOF
NAME="Came Linux"
VERSION="1.0.0"
ID=kwam
ID_LIKE=arch
PRETTY_NAME="Came Linux 1.0.0"
HOME_URL="https://kwamlinux.org"
EOF

echo "Base configuration complete!"
CHROOT_EOF

    log "System configured"
}

# ─── DESKTOP INSTALL ────────────────────────────────────────
install_desktop() {
    if [[ "$INSTALL_TYPE" == "1" ]]; then
        section "Installing Desktop (KDE Plasma)"

        arch-chroot /mnt /bin/bash << CHROOT_EOF
pacman -S --noconfirm \
    plasma-meta sddm kde-applications-meta \
    xorg-server pipewire pipewire-pulse wireplumber \
    ttf-jetbrains-mono noto-fonts noto-fonts-emoji \
    wine wine-mono winetricks bottles lutris \
    firefox kitty code vlc

systemctl enable sddm
CHROOT_EOF

        log "Desktop installed"
    else
        log "Skipping desktop (minimal install)"
    fi
}

# ─── SECURITY TOOLS ─────────────────────────────────────────
install_security() {
    section "Installing Security Tools"

    arch-chroot /mnt /bin/bash << CHROOT_EOF
pacman -S --noconfirm \
    nmap wireshark-qt aircrack-ng john hydra \
    sqlmap gobuster nikto netcat tcpdump \
    binwalk radare2 gdb strace ltrace \
    rkhunter lynis clamav firejail
CHROOT_EOF

    log "Security tools installed"
}

# ─── FINISH ─────────────────────────────────────────────────
finish() {
    section "Installation Complete!"

    umount -R /mnt
    swapoff -a

    echo ""
    log "Came Linux has been installed to $DISK"
    log "User: $USERNAME"
    log "Hostname: $HOSTNAME"
    echo ""
    echo -e "${CYAN}Remove the installation media and reboot:${NC}"
    echo "  reboot"
    echo ""
    echo -e "${GREEN}Welcome to Came Linux! 🚀${NC}"
}

# ─── MAIN ───────────────────────────────────────────────────
banner
gather_user_input
partition_disk
install_base
configure_system
install_security
install_desktop
finish
