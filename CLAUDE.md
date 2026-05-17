# Repository notes for Claude

This repo hosts multiple OpenSCAD projects under `projects/<name>/`.

## Rendering conventions

When generating preview / cutaway PNGs of a model, **always include
coordinate axes and an origin marker** in the render — colored X/Y/Z lines
from `(0,0,0)`, end-of-line axis labels, and a small marker at the origin.
This lets the user reference positions unambiguously when reviewing the
output ("move the boss to z=0", "rotate around the Y axis", etc.).

See `projects/karcher-wd2-adapter/docs/render.py::add_axes` for the
reference pattern. Apply the same convention when adding renderers for new
projects.
