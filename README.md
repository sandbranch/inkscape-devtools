# inkscape-devtools

Helpers for our Inkscape work, mainly for the Inkscape Flatpak
(`org.inkscape.Inkscape`, tested with 1.4.4).

- `flatpak-path.sh`: lets extensions in the Flatpak find programs such as
  `typst`, through one folder of links (`~/.local/share/inkscape-flatpak/bin`)
  added to the Flatpak's PATH. Only what is linked there is visible.
  `--undo` removes the setting again; `link PROGRAM` adds a program.
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
