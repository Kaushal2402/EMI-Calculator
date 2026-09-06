"""Generate the EMI Calculator app-icon master art (SOW D-04 / TASKS 9.1).

Writes three PNGs under assets/icon/:
  app_icon.png            1024x1024  full-bleed square master (iOS + legacy Android)
  app_icon_foreground.png 1024x1024  adaptive-icon foreground (glyph in safe zone)
  app_icon_monochrome.png 1024x1024  Android 13+ themed-icon monochrome layer

The rupee mark is drawn as vector strokes (the macOS build fonts here predate
U+20B9 and render tofu). Brand-blue vertical gradient ground
(Primary600 -> Primary800) with a soft lighter disc for depth.
"""
import os

from PIL import Image, ImageDraw, ImageFilter

S = 1024
SS = 4  # supersample factor for clean edges
PRIMARY_600 = (28, 116, 200)
PRIMARY_800 = (11, 69, 132)
WHITE = (255, 255, 255, 255)


def _vgradient(size, top, bottom):
    col = Image.new("RGB", (1, size))
    for y in range(size):
        t = y / (size - 1)
        col.putpixel(
            (0, y),
            tuple(round(top[i] + (bottom[i] - top[i]) * t) for i in range(3)),
        )
    return col.resize((size, size))


def _rupee(canvas, scale=1.0, fill=WHITE):
    """Draw the rupee mark centred on `canvas` (an RGBA Image). Coords in 0..1."""
    n = canvas.size[0]
    d = ImageDraw.Draw(canvas)
    cx = cy = 0.5

    dy = -0.022  # nudge the whole mark up so it sits optically centred

    def P(x, y):
        return (
            n * (cx + (x - cx) * scale),
            n * (cy + (y + dy - cy) * scale),
        )

    w = int(n * 0.072 * scale)
    r = w / 2

    def bar(p0, p1, round_ends=False):
        d.line([p0, p1], fill=fill, width=w)
        if round_ends:
            for px, py in (p0, p1):
                d.ellipse([px - r, py - r, px + r, py + r], fill=fill)

    # Two horizontal bars; the lower one over-hangs to the left (₹ signature).
    bar(P(0.40, 0.305), P(0.655, 0.305))
    bar(P(0.29, 0.435), P(0.655, 0.435))
    # Bowl: short vertical closing the two bars on the right.
    bar(P(0.6535, 0.305), P(0.6535, 0.435))
    # Stem down from the top bar, then the diagonal leg to the lower-right.
    bar(P(0.4035, 0.29), P(0.4035, 0.52))
    bar(P(0.399, 0.505), P(0.605, 0.70), round_ends=True)


def build_full():
    n = S * SS
    img = _vgradient(n, PRIMARY_600, PRIMARY_800).convert("RGBA")

    disc = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    m = int(n * 0.13)
    ImageDraw.Draw(disc).ellipse([m, m, n - m, n - m], fill=(255, 255, 255, 26))
    img = Image.alpha_composite(
        img, disc.filter(ImageFilter.GaussianBlur(n * 0.028)),
    )

    shadow = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    _rupee(shadow, fill=(0, 0, 0, 80))
    shadow = shadow.transform(
        (n, n), Image.AFFINE, (1, 0, 0, 0, 1, int(n * 0.014)),
    ).filter(ImageFilter.GaussianBlur(n * 0.010))
    img = Image.alpha_composite(img, shadow)

    fg = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    _rupee(fg)
    img = Image.alpha_composite(img, fg)
    return img.convert("RGB").resize((S, S), Image.LANCZOS)


def _mark_only(scale):
    n = S * SS
    layer = Image.new("RGBA", (n, n), (0, 0, 0, 0))
    _rupee(layer, scale=scale)
    return layer.resize((S, S), Image.LANCZOS)


def main():
    out = "assets/icon"
    os.makedirs(out, exist_ok=True)
    build_full().save(os.path.join(out, "app_icon.png"))
    _mark_only(0.66).save(os.path.join(out, "app_icon_foreground.png"))
    _mark_only(0.66).save(os.path.join(out, "app_icon_monochrome.png"))
    print("wrote", out, "/ app_icon{,_foreground,_monochrome}.png")


if __name__ == "__main__":
    main()
