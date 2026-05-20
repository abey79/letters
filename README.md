# 3D Print Projects

Collection of parametric OpenSCAD models. Each lives under `projects/<name>/`
and is self-contained — its own `justfile`, `README.md`, and `build/` output.

## Projects

| Project | Description |
| --- | --- |
| [`projects/letter-tags`](projects/letter-tags) | Gridfinity 1×1 letter tags with embedded magnets and a two-color flat top. |
| [`projects/karcher-wd2-adapter`](projects/karcher-wd2-adapter) | Kärcher WD2 hose → 63 mm tool port adapter, press-fit on the WD2 side, M3-clamped on the tool side. |

## Building

Requires `just` and `openscad` (snapshot ≥ 2024 for `lazy-union`). From the
repo root:

```sh
just                          # list recipes
just all                      # render every project
just clean                    # wipe every build/ dir
just p letter-tags one A      # run `one A` inside one project
```

Or `cd projects/<name>` and run `just` directly.

CI renders every project on every push and uploads one artifact per project.
