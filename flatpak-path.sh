#!/bin/sh
# Let extensions in the Inkscape Flatpak find programs they need (typst,
# optipng, pdflatex, fig2dev) without opening the sandbox: a folder of links,
# ~/.local/share/inkscape-flatpak/bin, is added to the Flatpak's PATH.
# Only programs linked there are visible, and they must run inside the
# sandbox (static binaries such as typst do).
#
#   flatpak-path.sh               set the override, link typst if found
#   flatpak-path.sh link PROGRAM  add a program to the folder
#   flatpak-path.sh --undo        remove the override (keeps the folder)
#
# Copyright 2026 David
# SPDX-License-Identifier: GPL-3.0-or-later
set -eu
app=org.inkscape.Inkscape
dir=${XDG_DATA_HOME:-$HOME/.local/share}/inkscape-flatpak/bin

case "${1:-}" in
--undo)
    # Remove only our PATH line from the override file. (flatpak override
    # --unset-env=PATH would instead unset PATH inside the sandbox.)
    file=${XDG_DATA_HOME:-$HOME/.local/share}/flatpak/overrides/$app
    if [ -f "$file" ]; then
        sed -i '/^PATH=.*inkscape-flatpak\/bin/d' "$file"
    fi
    flatpak override --user --show "$app"
    echo "PATH override removed"
    exit 0
    ;;
link)
    target=$(command -v "$2") || { echo "no $2 on PATH" >&2; exit 1; }
    mkdir -p "$dir"
    ln -sf "$(readlink -f "$target")" "$dir/$(basename "$2")"
    echo "linked $2 -> $(readlink -f "$target")"
    exit 0
    ;;
esac

mkdir -p "$dir"
if command -v typst >/dev/null 2>&1 || [ -x "$HOME/.local/bin/typst" ]; then
    typst=$(command -v typst || echo "$HOME/.local/bin/typst")
    ln -sf "$(readlink -f "$typst")" "$dir/typst"
fi

# Programs of the host system (Ubuntu packages), run inside the sandbox
# with the host's own loader and libraries: see host-wrappers/.
here=$(cd "$(dirname "$0")" && pwd)
cp "$here/host-wrappers/host-run" "$dir/.host-run"
cp "$here/host-wrappers/host-tex" "$dir/.host-tex"
chmod +x "$dir/.host-run" "$dir/.host-tex"
for prog in optipng fig2dev; do
    if [ -x "/usr/bin/$prog" ]; then ln -sf .host-run "$dir/$prog"; else rm -f "$dir/$prog"; fi
done
if [ -x /usr/bin/pdflatex ]; then
    ln -sf .host-tex "$dir/pdflatex"
    ln -sf .host-tex "$dir/kpsewhich"
    # The sandbox cannot see the host's /var/lib/texmf: copy the font maps
    # (pdflatex's format is built by the wrapper itself, inside).
    var=$HOME/.var/app/$app/data/inkscape-flatpak/texmf-var
    mkdir -p "$var/fonts"
    rm -rf "$var/fonts/map"
    cp -r /var/lib/texmf/fonts/map "$var/fonts/"
else
    rm -f "$dir/pdflatex" "$dir/kpsewhich"
fi
flatpak override --user --env=PATH="/app/bin:/usr/bin:$dir" "$app"
echo "Flatpak PATH now includes $dir:"
ls -l "$dir"
flatpak run --command=sh "$app" -c 'for p in typst optipng pdflatex fig2dev; do printf "%s: " $p; command -v $p || echo missing; done'
