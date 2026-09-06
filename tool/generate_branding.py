"""Generate EMI Calculator brand art from code (no external design source).

Outputs (all PNG, sRGB):
  assets/branding/icon_master.png      1024   full-bleed, gradient bg  -> iOS + legacy Android launcher
  assets/branding/icon_foreground.png  1024   transparent, safe-zone   -> Android adaptive foreground
  assets/branding/icon_background.png  1024   flat brand blue          -> Android adaptive background
  assets/branding/splash_logo.png      1152   transparent, white mark   -> native splash (light + dark)

Palette is taken verbatim from SOW section 6.1 / lib/core/constants/app_colors.dart.
The rupee mark is drawn geometrically (not typeset) so it stays crisp at every
density and never depends on a system font shipping the U+20B9 glyph.

Run:  python3 tool/generate_branding.py
"""
import os

from PIL import Image, ImageDraw

OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "branding")
os.makedirs(OUT, exist_ok=True)

PRIMARY       = (21, 101, 192)     # #1565C0
PRIMARY_LIGHT = (30, 111, 208)     # ~ primary 600  (splash gradient top)
PRIMARY_DARK  = (13, 71, 161)      # ~ primary 800  (splash gradient bottom)
PRIMARY_CONT  = (211, 228, 255)    # #D3E4FF
KEY_FILL      = (232, 237, 246)    # ~ surfaceVariant / #EEF2FA
SECONDARY     = (229, 57, 53)      # #E53935
WHITE         = (255, 255, 255)

SPRITE_W, SPRITE_H = 560, 700


def _rr(d, box, r, fill):
    d.rounded_rectangle(box, radius=r, fill=fill)


def _rupee(d, x, y, w, h, sw, fill):
    """Minimal geometric rupee sign inside (x, y, w, h)."""
    d.line([(x, y + sw / 2), (x + w, y + sw / 2)], fill=fill, width=sw)          # top bar
    d.line([(x, y + sw * 2.1), (x + w, y + sw * 2.1)], fill=fill, width=sw)      # 2nd bar
    d.line([(x + w * 0.60, y), (x + w * 0.60, y + h * 0.46)], fill=fill, width=sw)  # stem
    d.line([(x + w * 0.60, y + h * 0.46), (x, y + h)], fill=fill, width=sw)      # leg
    d.line([(x, y + sw * 2.1), (x + w * 0.60, y + sw * 2.1)], fill=fill, width=sw)


def build_calculator(mono_white=False):
    """Flat calculator glyph on a transparent SPRITE_W x SPRITE_H canvas."""
    img = Image.new("RGBA", (SPRITE_W, SPRITE_H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    display_fill = (255, 255, 255, 92) if mono_white else PRIMARY_CONT
    rupee_fill   = WHITE if mono_white else PRIMARY
    key_fill     = (255, 255, 255, 122) if mono_white else KEY_FILL
    accent_fill  = (255, 255, 255, 240) if mono_white else SECONDARY

    _rr(d, (0, 0, SPRITE_W, SPRITE_H), 64, WHITE)

    pad = 56
    inner_l, inner_r = pad, SPRITE_W - pad
    inner_w = inner_r - inner_l

    disp_top, disp_h = 56, 150
    _rr(d, (inner_l, disp_top, inner_r, disp_top + disp_h), 24, display_fill)
    gw, gh, sw = 62, 104, 16
    _rupee(d, inner_r - 34 - gw, disp_top + (disp_h - gh) / 2, gw, gh, sw, rupee_fill)

    grid_top = disp_top + disp_h + 44
    grid_bottom = SPRITE_H - pad
    gap = 26
    cell_w = (inner_w - 2 * gap) / 3
    cell_h = (grid_bottom - grid_top - 2 * gap) / 3
    for row in range(3):
        for col in range(3):
            x0 = inner_l + col * (cell_w + gap)
            y0 = grid_top + row * (cell_h + gap)
            fill = accent_fill if (row == 2 and col == 2) else key_fill
            _rr(d, (x0, y0, x0 + cell_w, y0 + cell_h), 18, fill)
    return img


def vgradient(size, top, bottom):
    w, h = size
    ramp = Image.new("L", (1, h))
    for y in range(h):
        ramp.putpixel((0, y), int(255 * y / (h - 1)))
    return Image.composite(
        Image.new("RGB", (w, h), bottom),
        Image.new("RGB", (w, h), top),
        ramp.resize((w, h)),
    )


def paste_centered(canvas, sprite, target_h):
    scale = target_h / sprite.height
    s = sprite.resize(
        (max(1, round(sprite.width * scale)), target_h), Image.LANCZOS
    )
    canvas.alpha_composite(
        s, ((canvas.width - s.width) // 2, (canvas.height - s.height) // 2)
    )


calc = build_calculator(mono_white=False)
calc_white = build_calculator(mono_white=True)

master = vgradient((1024, 1024), PRIMARY_LIGHT, PRIMARY_DARK).convert("RGBA")
paste_centered(master, calc, target_h=680)
master.convert("RGB").save(os.path.join(OUT, "icon_master.png"))

# flutter_launcher_icons adds its own ~16% inset on top of this, so the art is
# sized to fill the adaptive safe zone (~66/108) after that inset is applied.
fg = Image.new("RGBA", (1024, 1024), (0, 0, 0, 0))
paste_centered(fg, calc, target_h=760)
fg.save(os.path.join(OUT, "icon_foreground.png"))

Image.new("RGB", (1024, 1024), PRIMARY).save(os.path.join(OUT, "icon_background.png"))

splash = Image.new("RGBA", (1152, 1152), (0, 0, 0, 0))
paste_centered(splash, calc_white, target_h=432)
splash.save(os.path.join(OUT, "splash_logo.png"))

for n in ("icon_master.png", "icon_foreground.png", "icon_background.png",
          "splash_logo.png"):
    with Image.open(os.path.join(OUT, n)) as im:
        print(f"{n:22} {im.size} {im.mode}")
