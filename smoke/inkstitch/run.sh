#!/bin/sh
# Smoke test for an installed Ink/Stitch (~/.config/inkscape/extensions/inkstitch).
#
# 1. Exports the three test drawings (mm, px, 2 mm per user unit) to DST and
#    PES through Inkscape's --export-filename and checks them with pystitch.
# 2. Runs the Stitch Plan Preview action and the realistic 600 dpi raster
#    preview (the code path of inkstitch issue 4586).
# 3. With --gui, opens the simulator and params dialogs under Xvfb for 25 s
#    and saves screenshots (they are wxPython GUIs; this only shows they
#    start and draw, not that they behave).
#
# Needs a Python with pystitch: PYTHON=/path/to/venv/bin/python ./run.sh
# (python3 -m venv v && v/bin/pip install pystitch).
set -eu
here=$(cd "$(dirname "$0")" && pwd)
py=${PYTHON:-python3}
bin=${INKSTITCH_BIN:-$HOME/.config/inkscape/extensions/inkstitch/bin/inkstitch}
out=${OUT:-$(mktemp -d)}
echo "output in $out"
mkdir -p "$out"
cd "$out"

files=""
for d in mm px scaled; do
    cp "$here/$d.svg" .
    for f in dst pes; do
        dbus-run-session -- inkscape "$d.svg" --export-filename="$d.$f" >"$d.$f.log" 2>&1
        files="$files $d.$f"
    done
done
"$py" -I "$here/check_emb.py" $files

for d in mm px scaled; do
    dbus-run-session -- inkscape "$d.svg" \
        --actions="org.inkstitch.stitch-plan-preview.noprefs;export-filename:prev_$d.svg;export-do" \
        >"prev_$d.log" 2>&1
    grep -q __inkstitch_stitch_plan__ "prev_$d.svg" || { echo "FAIL preview $d"; exit 1; }
done
echo "stitch plan preview: ok in mm, px, scaled"

# dbus-run-session's helpers write to the inherited stdout, so keep only the SVG.
dbus-run-session -- "$bin" --extension=stitch_plan_preview --render-mode=realistic-600 mm.svg \
    >r600.raw 2>r600.err
sed -n '/^<\(svg\|!--\)/,$p' r600.raw >r600.svg
grep -q 'data:image/png;base64' r600.svg || { echo "FAIL realistic-600 preview"; cat r600.err; exit 1; }
echo "realistic 600 dpi preview: ok"

if [ "${1:-}" = "--gui" ]; then
    for e in simulator params; do
        env -u WAYLAND_DISPLAY GDK_BACKEND=x11 xvfb-run -a -s "-screen 0 1400x900x24" \
            dbus-run-session -- python3 -I "$here/gui_probe.py" "$e" mm.svg "$out/gui_$e.png" 25
    done
    echo "screenshots: $out/gui_simulator.png $out/gui_params.png"
fi
