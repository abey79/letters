# /// script
# requires-python = ">=3.10"
# dependencies = ["pyvista"]
# ///
"""Render README images from the OpenSCAD-exported STLs.

PyVista loads both bodies as separate meshes, optionally clips them with a
plane (true cutaway — no geometry mutation in OpenSCAD), and writes a PNG
with transparent background.
"""

import sys

import pyvista as pv

BODY_COLOR = "crimson"
OUTSIDE_COLOR = "black"
WINDOW = (1200, 1200)


def render(body_stl: str, outside_stl: str, out_png: str, mode: str) -> None:
    body = pv.read(body_stl)
    outside = pv.read(outside_stl)

    if mode == "cutaway":
        # Keep y >= -13 so the cut face passes through the front-row magnet
        # pockets. `clip_closed_surface` caps the cut with a new face so the
        # solid stays solid (vs `clip` which would leave an open hole).
        kwargs = dict(normal=(0.0, 1.0, 0.0), origin=(0.0, -13.0, 0.0))
        body = body.clip_closed_surface(**kwargs)
        outside = outside.clip_closed_surface(**kwargs)
    elif mode != "preview":
        sys.exit(f"unknown mode: {mode!r}")

    p = pv.Plotter(off_screen=True, window_size=WINDOW)
    p.add_mesh(body, color=BODY_COLOR, ambient=0.25, diffuse=0.75, specular=0.1)
    p.add_mesh(outside, color=OUTSIDE_COLOR, ambient=0.25, diffuse=0.75, specular=0.1)

    # 3/4 view from front-left-above. For cutaway, tilt closer to the cut
    # plane (smaller X offset, lower Z) so the exposed face shows more area.
    if mode == "cutaway":
        p.camera_position = [(25.0, -85.0, 45.0), (0.0, 0.0, 3.0), (0.0, 0.0, 1.0)]
    else:
        p.camera_position = [(50.0, -75.0, 55.0), (0.0, 0.0, 3.0), (0.0, 0.0, 1.0)]
    p.enable_parallel_projection()

    p.screenshot(out_png, transparent_background=True)


if __name__ == "__main__":
    if len(sys.argv) != 5:
        sys.exit("usage: render.py <body.stl> <outside.stl> <out.png> <preview|cutaway>")
    render(*sys.argv[1:])
