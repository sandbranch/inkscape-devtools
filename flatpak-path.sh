#!/bin/sh
# Let extensions in the Inkscape Flatpak find programs they need (typst,
# and later others) without opening the sandbox: a folder of links,
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
flatpak override --user --env=PATH="/app/bin:/usr/bin:$dir" "$app"
echo "Flatpak PATH now includes $dir:"
ls -l "$dir"
flatpak run --command=sh "$app" -c 'for p in typst; do printf "%s: " $p; command -v $p || echo missing; done'
