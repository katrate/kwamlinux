#!/bin/bash
# ============================================================
#  KWAM LINUX - KWin Animation & Effects Config
#  Premium macOS-like animations
# ============================================================

apply_kwin_effects() {
    # ── WINDOW ANIMATIONS ────────────────────────────────────
    kwriteconfig5 --file kwinrc --group Plugins \
        --key slideEnabled true \
        --key fadeEnabled true \
        --key scaleEnabled true \
        --key magiclampEnabled true \
        --key wobblywindowsEnabled true \
        --key blurEnabled true \
        --key contrastEnabled true \
        --key kwin4_effect_translucencyEnabled true \
        --key snaphelperEnabled false \
        --key desktopchangeosdEnabled false \
        --key zoomEnabled true \
        --key sheetEnabled true \
        --key fallapartEnabled false

    # ── BLUR (glassmorphism) ─────────────────────────────────
    kwriteconfig5 --file kwinrc --group Effect-Blur \
        --key BlurStrength 12 \
        --key NoiseStrength 2 \
        --key WindowOpacity 100

    # ── WINDOW OPEN/CLOSE (Scale like macOS) ─────────────────
    kwriteconfig5 --file kwinrc --group Effect-Scale \
        --key Duration 200 \
        --key ScaleInDuration 200 \
        --key ScaleOutDuration 160

    # ── MAGIC LAMP (macOS minimize to dock) ──────────────────
    kwriteconfig5 --file kwinrc --group Effect-MagicLamp \
        --key AnimationDuration 250

    # ── WOBBLY WINDOWS (subtle, premium) ─────────────────────
    kwriteconfig5 --file kwinrc --group Effect-WobblyWindows \
        --key Stiffness 15 \
        --key Drag 85 \
        --key WobbleFactor 15 \
        --key AdvancedMode false

    # ── DESKTOP SWITCH ───────────────────────────────────────
    kwriteconfig5 --file kwinrc --group Effect-Slide \
        --key Duration 300 \
        --key HorizontalGap 0

    # ── TRANSLUCENCY ─────────────────────────────────────────
    kwriteconfig5 --file kwinrc --group Effect-Translucency \
        --key Inactive 90 \
        --key MoveResize 80 \
        --key Dialogs 95 \
        --key ComboboxPopups 92

    # ── GENERAL KWIN ─────────────────────────────────────────
    kwriteconfig5 --file kwinrc --group General \
        --key AnimationSpeed 3 \
        --key BorderlessMaximizedWindows false

    # ── COMPOSITING ──────────────────────────────────────────
    kwriteconfig5 --file kwinrc --group Compositing \
        --key Backend OpenGL \
        --key GLCore true \
        --key Enabled true \
        --key LatencyPolicy Medium \
        --key OpenGLIsUnsafe false \
        --key WindowsBlockCompositing false \
        --key HiddenPreviews 5

    # ── WINDOW DECORATION ────────────────────────────────────
    kwriteconfig5 --file kwinrc --group org.kde.kdecoration2 \
        --key library org.kde.breeze \
        --key theme Breeze

    # ── WINDOW BEHAVIOR ──────────────────────────────────────
    kwriteconfig5 --file kwinrc --group Windows \
        --key FocusPolicy ClickToFocus \
        --key NextFocusPrefersMouse false \
        --key SeparateScreenFocus false \
        --key RollOverDesktops true \
        --key ElectricBorderCornerRatio 0.25

    # ── HOT CORNERS ──────────────────────────────────────────
    kwriteconfig5 --file kwinrc --group ElectricBorders \
        --key Top ShowDesktop \
        --key TopLeft Overview \
        --key TopRight ApplicationLauncher \
        --key BottomLeft None \
        --key BottomRight None

    # Restart KWin to apply
    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    echo "KWin animations configured!"
}

apply_kwin_effects
