#!/usr/bin/env python3
# ============================================================
#  KWAMLINUX - Wallpaper Generator
#  Generates premium SVG wallpapers for Kwamlinux Linux
# ============================================================

import os
import math

OUT_DIR = os.path.join(os.path.dirname(__file__), '..', 'output')
os.makedirs(OUT_DIR, exist_ok=True)

W, H = 1920, 1080

def save(name, svg):
    path = os.path.join(OUT_DIR, f'{name}.svg')
    with open(path, 'w') as f:
        f.write(svg)
    print(f'  ✔ {name}.svg')

# ── WALLPAPER 1: Deep Space Purple ───────────────────────────
def wallpaper_deep_space():
    circles = ''
    import random
    random.seed(42)
    for _ in range(180):
        x = random.randint(0, W)
        y = random.randint(0, H)
        r = random.uniform(0.5, 2.2)
        o = random.uniform(0.3, 0.95)
        circles += f'<circle cx="{x}" cy="{y}" r="{r}" fill="white" opacity="{o:.2f}"/>\n'

    svg = f'''<svg width="{W}" height="{H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="bg" cx="30%" cy="30%" r="80%">
      <stop offset="0%" stop-color="#1a0533"/>
      <stop offset="50%" stop-color="#0d0b1a"/>
      <stop offset="100%" stop-color="#050408"/>
    </radialGradient>
    <radialGradient id="orb1" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#7c3aed" stop-opacity="0.5"/>
      <stop offset="100%" stop-color="#7c3aed" stop-opacity="0"/>
    </radialGradient>
    <radialGradient id="orb2" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#4f46e5" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="#4f46e5" stop-opacity="0"/>
    </radialGradient>
    <filter id="blur1"><feGaussianBlur stdDeviation="80"/></filter>
    <filter id="blur2"><feGaussianBlur stdDeviation="60"/></filter>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#bg)"/>
  <!-- Glow orbs -->
  <ellipse cx="320" cy="280" rx="400" ry="350" fill="url(#orb1)" filter="url(#blur1)"/>
  <ellipse cx="1600" cy="750" rx="350" ry="300" fill="url(#orb2)" filter="url(#blur2)"/>
  <ellipse cx="960" cy="900" rx="250" ry="200" fill="#22d3ee" opacity="0.04" filter="url(#blur1)"/>
  <!-- Stars -->
  {circles}
  <!-- Logo watermark -->
  <g transform="translate(880, 460)" opacity="0.07">
    <polygon points="80,0 160,140 0,140" fill="#8b5cf6"/>
  </g>
  <!-- Subtle grid -->
  <g opacity="0.025" stroke="white" stroke-width="0.5">
    {''.join(f'<line x1="{x}" y1="0" x2="{x}" y2="{H}"/>' for x in range(0, W, 120))}
    {''.join(f'<line x1="0" y1="{y}" x2="{W}" y2="{y}"/>' for y in range(0, H, 120))}
  </g>
</svg>'''
    save('kwamlinux-deep-space', svg)

# ── WALLPAPER 2: Mesh Gradient ────────────────────────────────
def wallpaper_mesh():
    svg = f'''<svg width="{W}" height="{H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g1" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#0f0c29"/>
      <stop offset="100%" stop-color="#302b63"/>
    </linearGradient>
    <radialGradient id="r1" cx="20%" cy="20%" r="60%">
      <stop offset="0%" stop-color="#7c3aed" stop-opacity="0.6"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <radialGradient id="r2" cx="80%" cy="70%" r="50%">
      <stop offset="0%" stop-color="#22d3ee" stop-opacity="0.3"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <radialGradient id="r3" cx="60%" cy="10%" r="40%">
      <stop offset="0%" stop-color="#ec4899" stop-opacity="0.25"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <filter id="f1"><feGaussianBlur stdDeviation="120"/></filter>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#g1)"/>
  <rect width="{W}" height="{H}" fill="url(#r1)" filter="url(#f1)"/>
  <rect width="{W}" height="{H}" fill="url(#r2)" filter="url(#f1)"/>
  <rect width="{W}" height="{H}" fill="url(#r3)" filter="url(#f1)"/>
  <!-- Noise grain effect via subtle pattern -->
  <filter id="noise"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="4" stitchTiles="stitch"/>
    <feColorMatrix type="saturate" values="0"/><feBlend in="SourceGraphic" mode="overlay" result="blend"/>
  </filter>
  <rect width="{W}" height="{H}" filter="url(#noise)" opacity="0.03"/>
</svg>'''
    save('kwamlinux-mesh', svg)

# ── WALLPAPER 3: Geometric Lines ─────────────────────────────
def wallpaper_geometric():
    lines = ''
    step = 80
    for i in range(-H, W + H, step):
        lines += f'<line x1="{i}" y1="0" x2="{i + H}" y2="{H}" stroke="rgba(139,92,246,0.08)" stroke-width="1"/>\n'
    for i in range(0, W + H, step):
        lines += f'<line x1="{i}" y1="0" x2="{i - H}" y2="{H}" stroke="rgba(34,211,238,0.04)" stroke-width="1"/>\n'

    svg = f'''<svg width="{W}" height="{H}" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#050408"/>
      <stop offset="50%" stop-color="#0d0b1a"/>
      <stop offset="100%" stop-color="#0a0618"/>
    </linearGradient>
    <radialGradient id="glow" cx="50%" cy="50%" r="50%">
      <stop offset="0%" stop-color="#6d28d9" stop-opacity="0.2"/>
      <stop offset="100%" stop-color="transparent"/>
    </radialGradient>
    <filter id="blur"><feGaussianBlur stdDeviation="100"/></filter>
  </defs>
  <rect width="{W}" height="{H}" fill="url(#bg)"/>
  {lines}
  <ellipse cx="960" cy="540" rx="600" ry="400" fill="url(#glow)" filter="url(#blur)"/>
  <!-- Center logo -->
  <g transform="translate(900, 470)" opacity="0.06">
    <polygon points="60,0 120,104 0,104" fill="#a78bfa"/>
    <polygon points="60,20 100,88 20,88" fill="none" stroke="#22d3ee" stroke-width="1"/>
  </g>
</svg>'''
    save('kwamlinux-geometric', svg)

# ── INSTALLER SCRIPT ─────────────────────────────────────────
def write_installer():
    path = os.path.join(OUT_DIR, '..', 'install-wallpapers.sh')
    with open(path, 'w') as f:
        f.write('''#!/bin/bash
# Install Kwamlinux wallpapers
set -e
OUT="$(dirname "$0")/output"
DEST="/usr/share/wallpapers/kwamlinux"
sudo mkdir -p "$DEST"
for svg in "$OUT"/*.svg; do
    name=$(basename "$svg" .svg)
    sudo cp "$svg" "$DEST/$name.svg"
    echo "  ✔ Installed $name"
done
# Set default wallpaper via plasma
plasma-apply-wallpaperimage "$DEST/kwamlinux-deep-space.svg" 2>/dev/null || true
echo "Wallpapers installed!"
''')
    os.chmod(path, 0o755)
    print('  ✔ install-wallpapers.sh')

print('Generating Kwamlinux wallpapers...')
wallpaper_deep_space()
wallpaper_mesh()
wallpaper_geometric()
write_installer()
print('Done! Wallpapers saved to output/')
