"""Launch an Ink/Stitch GUI extension on the current X display, screenshot it, then stop it.

Usage: python gui_probe.py EXTENSION IN.svg SHOT.png SECONDS
"""

import os, subprocess, sys, time
ext, svg, shot, wait = sys.argv[1], sys.argv[2], sys.argv[3], float(sys.argv[4])
binp = os.path.expanduser("~/.config/inkscape/extensions/inkstitch/bin/inkstitch")
p = subprocess.Popen([binp, f"--extension={ext}", svg], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
t0 = time.time()
while time.time() - t0 < wait and p.poll() is None:
    time.sleep(0.5)
alive = p.poll() is None
subprocess.run(["import", "-window", "root", shot])
if alive:
    p.terminate()
out, err = p.communicate(timeout=20)
print(f"{ext}: alive_after_{wait}s={alive} rc={p.returncode} stdout_bytes={len(out)}")
print("STDERR:\n" + err.decode(errors="replace")[-3000:])
