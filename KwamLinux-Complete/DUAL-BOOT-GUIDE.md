# Kwamlinux Linux — Dual Boot Guide (Windows + Kwamlinux)

> How to install Kwamlinux alongside Windows on your laptop.

---

## What You Need

- A Windows laptop (Windows 10 or 11)
- A USB drive — **at least 8GB** (everything on it will be erased)
- The Kwamlinux ISO (built from this project)
- **Rufus** (free Windows tool) — https://rufus.ie
- About **30–50GB of free space** on your hard drive

---

## STEP 1 — Build the ISO (on an Arch Linux PC or VM)

If you don't have an Arch machine, skip to **Step 1B**.

```bash
sudo pacman -S archiso
cd KwamLinux-Complete
sudo ./build.sh
# ISO will be saved to: output/kwamlinux-*.iso
```

### Step 1B — Use Arch ISO temporarily
If you can't build yet, download the official Arch ISO from https://archlinux.org/download
and run the Kwamlinux installer manually from USB. The team will release a
pre-built ISO at https://kwamlinux.org (coming soon).

---

## STEP 2 — Make Free Space on Windows

1. Press `Windows + X` → click **Disk Management**
2. Right-click your **C: drive** → click **Shrink Volume**
3. Shrink by **40000 MB** (40GB minimum, 60GB recommended)
4. You will see **Unallocated space** — leave it as is
5. Close Disk Management

---

## STEP 3 — Disable Fast Startup (IMPORTANT)

Windows Fast Startup can block Linux from booting.

1. Go to **Control Panel** → **Power Options**
2. Click **Choose what the power buttons do**
3. Click **Change settings that are currently unavailable**
4. **Uncheck** "Turn on fast startup"
5. Click **Save changes**

---

## STEP 4 — Flash ISO to USB with Rufus

1. Download **Rufus** from https://rufus.ie and open it
2. Insert your USB drive
3. Under **Device** — select your USB drive
4. Under **Boot selection** — click **SELECT** → choose the Kwamlinux ISO
5. **Partition scheme** → select **GPT** (for UEFI, which most modern laptops use)
6. **Target system** → select **UEFI (non-CSM)**
7. Click **START** → click **OK** on any warnings
8. Wait for it to finish (3–5 minutes)

---

## STEP 5 — Boot from USB

1. **Shut down** your Windows laptop completely
2. Plug in the USB drive
3. Power on and immediately press the boot key:

| Laptop Brand | Boot Key |
|---|---|
| Dell | F12 |
| HP | F9 or Esc |
| Lenovo | F12 or Novo button |
| Asus | Esc or F8 |
| Acer | F12 |
| MSI | F11 |
| Surface | Hold Volume Down + Power |

4. Select your **USB drive** from the boot menu
5. You will see the Kwamlinux boot screen

---

## STEP 6 — Disable Secure Boot (if needed)

If your laptop shows a Secure Boot error:

1. Restart and enter BIOS/UEFI (usually F2 or Delete on startup)
2. Find **Secure Boot** → set to **Disabled**
3. Save and exit (usually F10)
4. Boot from USB again

---

## STEP 7 — Run the Kwamlinux Installer

Once booted into the live Kwamlinux environment, open a terminal and run:

```bash
sudo bash /INSTALL-ALL.sh
```

The installer will ask you:

| Question | What to enter |
|---|---|
| Target disk | `/dev/sda` or `/dev/nvme0n1` (your laptop's drive) |
| Username | Your desired username |
| Hostname | e.g. `my-kwamlinux` |
| Timezone | e.g. `Asia/Kolkata` or `America/New_York` |
| Install type | `1` for Full Desktop |

> ⚠️ **When selecting the disk — do NOT select the USB drive.
> Select your laptop's internal drive (usually /dev/sda or /dev/nvme0n1).**

The installer will:
- Detect your existing Windows partition and leave it alone
- Create a new Kwamlinux partition in the free space you made in Step 2
- Install GRUB bootloader which gives you the choice of OS at startup

---

## STEP 8 — Reboot & Choose Your OS

1. Remove the USB drive when installation finishes
2. Reboot your laptop
3. You will see the **GRUB boot menu** with two options:
   - **Kwamlinux Linux** ← your new OS
   - **Windows Boot Manager** ← your existing Windows

Use arrow keys to select and press Enter.

---

## After Installation — First Steps

Boot into Kwamlinux and run:

```bash
# Update everything
kwamlinux update

# Install security tools
kwamlinux security install

# Harden your system
kwamlinux harden

# Check system status
kwamlinux status
```

---

## Troubleshooting

**GRUB doesn't show / boots straight to Windows:**
- Restart → enter BIOS → change boot order so "Kwamlinux" or "GRUB" is first

**No WiFi after install:**
```bash
nmtui   # opens a simple network manager UI
```

**Screen too bright / too dark:**
- Go to System Settings → Display → Brightness

**Windows won't boot:**
- Boot into Kwamlinux → open terminal → run:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

## To Remove Kwamlinux (Uninstall)

1. Boot into Windows
2. Open **Disk Management**
3. Delete the Kwamlinux partition(s)
4. Extend C: drive back into the free space
5. Run Windows Recovery to fix the bootloader:
```
bootrec /fixmbr
bootrec /fixboot
bootrec /rebuildbcd
```

---

*Kwamlinux Linux — Security. Style. Power.*
