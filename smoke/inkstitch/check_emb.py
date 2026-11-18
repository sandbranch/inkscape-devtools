"""Read embroidery files back with pystitch and check them against the test drawing.

The drawings (mm.svg, px.svg, scaled.svg) all hold a 40 x 30 mm filled
rectangle and a 60 mm running-stitch line 20 mm below it, so every output
must span 60 x 50 mm in two colour blocks.

Usage: python check_emb.py FILE...   (exit status 1 if any check fails)
"""
import sys

import pystitch
from pystitch import COLOR_CHANGE, END, JUMP, STITCH, STOP, TRIM

NAMES = {STITCH: "stitch", JUMP: "jump", TRIM: "trim",
         COLOR_CHANGE: "color_change", END: "end", STOP: "stop"}
TOL = 0.15  # mm; formats store 0.1 mm units


def extents(stitches):
    xs = [s[0] for s in stitches if s[2] & 0xFF == STITCH]
    ys = [s[1] for s in stitches if s[2] & 0xFF == STITCH]
    return len(xs), (max(xs) - min(xs)) / 10, (max(ys) - min(ys)) / 10


def check(fn):
    p = pystitch.read(fn)
    if p is None:
        return [f"{fn}: unreadable"]
    counts = {}
    for _x, _y, c in p.stitches:
        k = NAMES.get(c & 0xFF, c & 0xFF)
        counts[k] = counts.get(k, 0) + 1
    n, w, h = extents(p.stitches)
    blocks = [extents(b) for b, _t in p.get_as_colorblocks()]
    blocks = [b for b in blocks if b[0]]
    print(f"{fn}: {counts} extents {w:.2f} x {h:.2f} mm; blocks "
          + ", ".join(f"n={b[0]} {b[1]:.2f}x{b[2]:.2f}" for b in blocks))
    errors = []
    if abs(w - 60) > TOL or abs(h - 50) > TOL:
        errors.append(f"{fn}: extents {w:.2f} x {h:.2f}, expected 60 x 50 mm")
    if len(blocks) != 2:
        errors.append(f"{fn}: {len(blocks)} colour blocks, expected 2")
    elif abs(blocks[0][1] - 40) > TOL or abs(blocks[0][2] - 30) > TOL:
        errors.append(f"{fn}: fill block {blocks[0][1]:.2f} x {blocks[0][2]:.2f}, expected 40 x 30 mm")
    if n < 1000:
        errors.append(f"{fn}: only {n} stitches")
    return errors


if __name__ == "__main__":
    errs = [e for fn in sys.argv[1:] for e in check(fn)]
    for e in errs:
        print("FAIL", e)
    sys.exit(1 if errs else 0)
