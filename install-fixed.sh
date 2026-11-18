#!/bin/sh
# Install fixed copies of Inkscape's built-in extensions from our branches
# of inkscape/extensions, until Inkscape ships the fixes. A user extension
# with the same id as a built-in one is ignored (checked with 1.4.4), so
# each copy gets an id under org.sandbranch and ", fixed" in its name.
#
#   install-fixed.sh [path to inkscape-extensions checkout]
#   install-fixed.sh --uninstall
#
# Fixes (branch: files):
#   typst-formula-glyphs: typst_formula (whole formula with typst 0.15)
#
# Copyright 2026 David
# SPDX-License-Identifier: GPL-3.0-or-later
set -eu
if flatpak info org.inkscape.Inkscape >/dev/null 2>&1; then
    ext=$HOME/.var/app/org.inkscape.Inkscape/config/inkscape/extensions
else
    ext=${XDG_CONFIG_HOME:-$HOME/.config}/inkscape/extensions
fi
if [ "${1:-}" = --uninstall ]; then
    rm -rf "$ext/typst-fixed"
    echo "removed fixed copies from $ext"
    exit 0
fi
src=$(cd "${1:-$(dirname "$0")/../inkscape-extensions}" && pwd)

install_fixed () {  # branch folder name file-stem
    branch=$1 folder=$2 name=$3 stem=$4
    dest=$ext/$folder
    mkdir -p "$dest"
    git -C "$src" show "$branch:$stem.py" > "$dest/$stem.py"
    git -C "$src" show "$branch:$stem.inx" |
        sed -e "s|<id>org\.inkscape\.|<id>org.sandbranch.|" \
            -e "s|<name>$name</name>|<name>$name, fixed</name>|" > "$dest/$stem.inx"
    grep -q "org.sandbranch" "$dest/$stem.inx" || { echo "id not changed in $stem.inx" >&2; exit 1; }
    echo "installed $name (fixed) from $branch into $dest"
}

install_fixed typst-formula-glyphs typst-fixed "Formula (typst)" typst_formula
echo "restart Inkscape"
