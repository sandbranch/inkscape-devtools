# inkscape-devtools

Helpers for our Inkscape work, mainly for the Inkscape Flatpak
(`org.inkscape.Inkscape`, tested with 1.4.4).

- `flatpak-path.sh`: lets extensions in the Flatpak find the programs they
  call, through one folder (`~/.local/share/inkscape-flatpak/bin`) added
  to the Flatpak's PATH. Only what is put there is visible. It links
  `typst` (a static binary, runs as is) and, if your system has them,
  `optipng`, `pdflatex` and `fig2dev`, through the wrappers in
  `host-wrappers/`: they run the host's own program inside the sandbox
  with the host's loader and libraries (the host's `/usr` is visible at
  `/run/host/usr`), so the sandbox stays closed. For TeX, the wrapper
  points TeX's trees at `/run/host`, builds pdflatex's format in a folder
  of its own (the sandbox cannot see the host's `/var`; rebuilt when
  pdfTeX is updated), and the script copies the font maps there. Run it
  again after installing TeX fonts. `--undo` removes the PATH setting;
  `link PROGRAM` adds a static program.

  This fixes the built-in Formula (typst), Formula (pdflatex) and
  Optimized PNG outputs, and XFIG Input once `fig2dev` is installed.
- `install-fixed.sh`: installs fixed copies of built-in extensions from
  our branches of [inkscape/extensions](https://gitlab.com/inkscape/extensions)
  until Inkscape ships the fixes. A user extension with the same id as a
  built-in one is ignored, so each copy gets an `org.sandbranch` id and
  ", fixed" in its menu name. Current fixes:
  - **Formula (typst)**: with typst 0.15 every glyph landed on the same
    spot (branch `typst-formula-glyphs`).

Facts about the Inkscape Flatpak these rely on (checked 2026-11-18):
filesystems=host, but a private `/tmp`; no USB or serial devices; PATH
inside is `/app/bin:/usr/bin`; a static binary like typst runs inside.

Related: [inkscape-xcf-export](https://github.com/sandbranch/inkscape-xcf-export),
[gimp-devtools](https://github.com/sandbranch/gimp-devtools).

GPL-3.0-or-later, see `COPYING`.
