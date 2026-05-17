# /// script
# requires-python = ">=3.10"
# dependencies = ["pyvista"]
# ///
"""Render preview and axial-cutaway PNGs of the WD2 adapter.

The cutaway clips the body with a vertical plane through the adapter's axis
(normal = Y), capping the cut so the cross-section reads as a solid wall —
you can see the bore profile, the press-fit taper, and the clamp slot.
"""

import sys

import pyvista as pv

BODY_COLOR = "steelblue"
WINDOW = (1200, 1200)


def render(stl_path: str, out_png: str, mode: str) -> None:
    mesh = pv.read(stl_path)

    if mode == "cutaway":
        # YZ plane through the axis — keeps the +Y half so the bore opens
        # toward the camera.
        mesh = mesh.clip_closed_surface(
            normal=(0.0, -1.0, 0.0), origin=(0.0, 0.0, 0.0)
        )
    elif mode != "preview":
        sys.exit(f"unknown mode: {mode!r}")

    p = pv.Plotter(off_screen=True, window_size=WINDOW)
    p.add_mesh(mesh, color=BODY_COLOR, ambient=0.25, diffuse=0.75, specular=0.1)

    # 3/4 view: front-right-above, aimed at the middle of the part.
    p.camera_position = [(110.0, -130.0, 75.0), (0.0, 0.0, 45.0), (0.0, 0.0, 1.0)]
    p.enable_parallel_projection()

    p.screenshot(out_png, transparent_background=True)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("usage: render.py <stl> <out.png> <preview|cutaway>")
    render(*sys.argv[1:])
