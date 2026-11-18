# Brief: reviving third-party Inkscape extensions (shared by all agents)

David asked for this work to run unattended overnight (2026-11-18). Work
on your own; nobody can answer questions until morning.

## Machine

- Inkscape 1.4.3, native, `/usr/bin/inkscape`. inkex 1.4 is only in
  `/usr/share/inkscape/extensions` (set `PYTHONPATH` to it for tests).
  System Python 3.14 (shapely, scipy, numpy, lxml present).
- User extensions folder: `~/.config/inkscape/extensions`. Install by
  symlinking from the repo (look at `../inkscape-halftone/dev/install.sh`
  for the pattern), so a later fix needs no reinstall.
- Other agents run Inkscape at the same time. ALWAYS wrap Inkscape in
  `dbus-run-session -- inkscape ...`, or parallel runs render nothing.
- The command line passes no selection to extensions. Run an extension
  with `inkscape in.svg --actions="<inx id>.noprefs;export-filename:out.svg;export-do"`
  or call the .py directly: `python3 ext.py --id=obj1 --opt=... in.svg > out.svg`
  with `PYTHONPATH=/usr/share/inkscape/extensions`.
- Use your scratchpad for throwaway files; anything worth keeping
  (tests, helpers, sample drawings) goes in the repo.

## Inkscape 1.x gotchas we have hit before

- `svg.unittouu` ignores the viewBox. Real px per user unit is
  `svg.scale`; for mm use `svg.viewport_to_unit("1mm")`. Inkscape 1.x
  makes new documents in mm (A4, 1 user unit = 1 mm = 3.78 px). Test
  every geometry extension in three documents: mm (viewBox 0 0 210 297,
  width 210mm), px (no viewBox) and a scaled one (2 mm per user unit).
  Extensions written for px documents usually draw at the wrong size.
- .inx files: the `<dependency>inkex.py</dependency>` line stops an
  extension loading since 1.0; `_name`/`_gui-text` became
  `name`/`gui-text`; `boolean` became `bool`; `description` became `label`.
- inkex `BoundingBox` union is `+`, not `|`. Text bounding boxes are
  unreliable when user units are not px.
- Python 3.14 argparse rejects a bare `%` in help strings.

## What to do per extension

1. Clone upstream into `/home/david/store/code/sandbranch/<repo name>`
   (if you will change code, fork first: `gh repo fork <owner/repo>
   --clone=false --org` is NOT needed; plain `gh repo fork owner/repo
   --clone=false` forks to the sandbranch account). Read the code.
2. Install it and run it on real drawings in Inkscape 1.4.3, through the
   command line, in the three document kinds. Export a PNG of the result
   and LOOK at it (Read the PNG) to check it is right, not just that it
   ran. Measure sizes where the extension promises a size.
3. If it is broken: fix it on a branch `inkscape-1.4` in the sandbranch
   fork, with pytest tests that fail on the upstream code and pass on
   the fix, a GitHub Actions workflow (Python 3.10 to 3.14, inkex 1.4 via
   `pip install --no-deps inkex==1.4.0` plus lxml<7, numpy, pillow,
   tinycss2, cssselect, pyparsing, packaging, and whatever the extension
   needs), and a short note at the top of the README saying what the
   branch fixes. Set the branch as the fork's default
   (`gh repo edit sandbranch/<repo> --default-branch inkscape-1.4`).
   Push. Check CI goes green (`gh run list`, `gh run watch`).
4. If it already works: no fork. Just leave it installed and report.
5. Search upstream's issues for the bugs you find (`gh issue list -R
   owner/repo --state all --search ...`) and note matching issue numbers.

## Hard rules

- NO outward posts: no upstream issues, PRs or comments. Pushing to
  sandbranch forks is fine. Upstream contact needs David's approval.
- Never write an em-dash or en-dash anywhere (code, comments, commits,
  READMEs, reports). Don't lean on " - " as a clause joiner either.
- Verify before claiming. Say plainly what you did not test.
- Credits go in README, never in an About dialog.
- Commits: git user.name David, user.email sandquist@gmail.com (set per
  repo with `git config`), message ends with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Don't touch other agents' extensions or the repos listed under
  /home/david/store/code/sandbranch that aren't yours.
- Don't use `sleep` in Bash (blocked); wait on CI with `gh run watch`.

## Report back (final message)

Short and factual: what works as is, what was broken and how you fixed
it (commit and CI links), tests count, what you could not test and why,
matching upstream issue numbers, and anything David must decide.
