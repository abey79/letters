# /// script
# requires-python = ">=3.10"
# dependencies = ["pyvista"]
# ///
"""Render preview, axial-cutaway and through-boss PNGs of the WD2 adapter."""

import sys

import pyvista as pv

BODY_COLOR = "steelblue"
WINDOW = (1200, 1200)
AXIS_LEN = 50
AXIS_COLORS = {"X": "crimson", "Y": "forestgreen", "Z": "royalblue"}

# Z height of the boss centerline — pulled from wd2_adapter.scad so the
# through-boss cut slices exactly through the screw axis.
BOSS_CENTER_Z = 5.0


def add_axes(p: pv.Plotter) -> None:
    """Draw X / Y / Z lines from the origin with end labels, plus an origin
    marker. Helps the user reference coordinates when commenting on a render.
    """
    for axis, end in [
        ("X", (AXIS_LEN, 0, 0)),
        ("Y", (0, AXIS_LEN, 0)),
        ("Z", (0, 0, AXIS_LEN)),
    ]:
        color = AXIS_COLORS[axis]
        p.add_mesh(pv.Line((0, 0, 0), end), color=color, line_width=4)
        p.add_point_labels(
            [end], [axis],
            font_size=28, text_color=color, bold=True,
            shape=None, show_points=False, always_visible=True,
        )
    p.add_mesh(pv.Sphere(radius=1.2, center=(0, 0, 0)), color="black")


def render(stl_path: str, out_png: str, mode: str) -> None:
    mesh = pv.read(stl_path)
    p = pv.Plotter(off_screen=True, window_size=WINDOW)

    if mode == "preview":
        # 3/4 view from front-right-above.
        p.camera_position = [
            (140.0, -170.0, 90.0), (0.0, 0.0, 45.0), (0.0, 0.0, 1.0),
        ]
    elif mode == "cutaway":
        # Axial cut at Y=0. Keep the -Y half (the side with the nut trap)
        # so the cross-section shows the bore, the press-fit taper, the
        # conical reducer AND the -Y boss with its hex nut pocket.
        mesh = mesh.clip_closed_surface(
            normal=(0.0, -1.0, 0.0), origin=(0.0, 0.0, 0.0)
        )
        p.camera_position = [
            (35.0, 180.0, 70.0), (0.0, 0.0, 45.0), (0.0, 0.0, 1.0),
        ]
    elif mode == "boss":
        # Horizontal cut through the boss centerline so the slot, the boss
        # profile, the boss/cylinder junction, the screw bore and the hex
        # nut trap all appear in one plan view. Centered on +X so the boss
        # detail fills the frame.
        mesh = mesh.clip_closed_surface(
            normal=(0.0, 0.0, 1.0), origin=(0.0, 0.0, BOSS_CENTER_Z)
        )
        p.camera_position = [
            (20.0, 0.0, 140.0), (20.0, 0.0, BOSS_CENTER_Z), (0.0, 1.0, 0.0),
        ]
    else:
        sys.exit(f"unknown mode: {mode!r}")

    p.add_mesh(mesh, color=BODY_COLOR, ambient=0.25, diffuse=0.75, specular=0.1)
    add_axes(p)

    p.enable_parallel_projection()
    p.camera.parallel_scale = 80 if mode != "boss" else 32

    p.screenshot(out_png, transparent_background=True)


if __name__ == "__main__":
    if len(sys.argv) != 4:
        sys.exit("usage: render.py <stl> <out.png> <preview|cutaway|boss>")
    render(*sys.argv[1:])
