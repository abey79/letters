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
    p = pv.Plotter(off_screen=True, window_size=WINDOW)

    if mode == "preview":
        # 3/4 view from front-right-above.
        p.camera_position = [
            (140.0, -170.0, 90.0), (0.0, 0.0, 45.0), (0.0, 0.0, 1.0),
        ]
    elif mode == "cutaway":
        # Half cut along the adapter axis: drop the camera-side half so the
        # bore, the press-fit taper, the conical reducer, and the slot
        # extending into the transition all read as a clean cross-section.
        # clip_closed_surface keeps the half where (point · normal) >= 0,
        # so normal=(0,1,0) keeps +Y and the cut face at y=0 faces the
        # camera sitting at -Y.
        mesh = mesh.clip_closed_surface(
            normal=(0.0, 1.0, 0.0), origin=(0.0, 0.0, 0.0)
        )
        p.camera_position = [
            (35.0, -180.0, 70.0), (0.0, 0.0, 45.0), (0.0, 0.0, 1.0),
        ]
    else:
        sys.exit(f"unknown mode: {mode!r}")

    p.add_mesh(mesh, color=BODY_COLOR, ambient=0.25, diffuse=0.75, specular=0.1)

    # Lock orthographic framing wide enough that the whole 90 mm part fits
    # with comfortable margin on all sides.
    p.enable_parallel_projection()
    p.camera.parallel_scale = 80

    p.screenshot(out_png, transparent_background=True)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("usage: render.py <stl> <out.png> <preview|cutaway>")
    render(*sys.argv[1:])
