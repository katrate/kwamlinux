# Came Linux 🐉

> **Security. Style. Power.**

Came Linux is a rolling-release, Arch-based Linux distribution combining:
- 🔒 **Kali-level** security & hacking tools
- 🎨 **Arch-level** customizability  
- 🍎 **macOS-level** premium feel
- 🪟 **Windows app** compatibility via Wine/Proton

---

## Current Status: Phase 1 (Base System) ✅

### What's Built
- [x] Base system config (Arch-based)
- [x] Package list (base + security + desktop + Wine)
- [x] ISO build script (`build.sh`)
- [x] Interactive installer (`scripts/install.sh`)
- [x] System hardening (UFW, SSH, AppArmor)
- [x] ZSH config with Came branding
- [x] Neofetch branding

### Coming Next
- [ ] Custom KDE Plasma theme (Phase 2)
- [ ] Came package manager wrapper (`kwam`)
- [ ] Custom welcome app
- [ ] Came wallpapers & icons
- [ ] Website

---

## Building the ISO

### Requirements
- Arch Linux host (or Arch-based distro)
- `archiso` package installed
- Root access
- ~10GB free space
- Internet connection

### Steps

```bash
# 1. Install archiso
sudo pacman -S archiso

# 2. Clone / enter the project
cd kwamlinux

# 3. Build the ISO
sudo ./build.sh

# 4. Test in QEMU
qemu-system-x86_64 -m 4G -cdrom output/kwamlinux-*.iso -boot d -enable-kvm

# 5. Flash to USB
sudo dd if=output/kwamlinux-*.iso of=/dev/sdX bs=4M status=progress
```

---

## Installing to Disk

Boot from the ISO, then run:

```bash
sudo bash /came-install
```

The installer will:
1. Ask for disk, username, hostname, timezone
2. Partition & format the disk
3. Install base system
4. Install security tools
5. Install KDE Plasma desktop (optional)
6. Configure bootloader (GRUB, UEFI/BIOS auto-detect)

---

## Project Structure

```
kwamlinux/
├── build.sh                    # ISO build script
├── config/
│   └── packages.x86_64        # All packages to include
├── airootfs/
│   ├── etc/
│   │   ├── kwamlinux-release  # OS identity
│   │   ├── hostname
│   │   ├── motd
│   │   └── skel/              # Default user files
│   └── usr/
│       └── bin/               # Custom commands
└── scripts/
    └── install.sh             # Disk installer
```

---

## Philosophy

Came Linux believes:
- Power users deserve beautiful tools
- Security should be accessible
- Customization is a right, not a privilege

---

*Built with ❤️ — Came Linux Project*
