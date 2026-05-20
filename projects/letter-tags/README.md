# Gridfinity Letter Tags

Parametric OpenSCAD model for 1×1 [Gridfinity](https://gridfinity.xyz)-compatible
letter tags, designed to print upside-down with a single filament swap for a
clean two-color flat top.

![preview](docs/preview.png)

## How it works

- Standard Gridfinity 1×1 base (41.5 mm, R3.75, official profile) on the bottom.
- Flat top with the letter raised at the original top plane and the background
  recessed by `color_layers × layer_height` (default **3 × 0.2 mm = 0.6 mm**).
- Four 6×2 mm magnet pockets are embedded at the canonical Gridfinity corner
  positions (±13 mm from center). Each pocket is a loose cylindrical cavity
  (default **6.45 mm Ø**) with **three vertical bumps at 120°** protruding
  inward — the inscribed diameter through the bump tips (`magnet_d`,
  default **5.85 mm**) is the actual press-fit dimension. The bumps taper
  from a point to full size over `magnet_bump_chamfer` (default **0.6 mm**)
  on the entry side, so the magnet slides in and only engages the press fit
  once seated. A **`magnet_cover_layers × layer_height`** ceiling (default
  **2 × 0.2 mm = 0.4 mm**) sits between each magnet and the base bottom and
  bridges cleanly across the cavity.

## Printing

Print **letter face down on the build plate** at 0.2 mm layer height. You'll
need two pauses in your slicer:

| Pause z (mm) | Action                                                      |
| ------------ | ----------------------------------------------------------- |
| `0.6`        | Filament swap: letter color → background color              |
| `5.6`        | Drop a 6×2 mm magnet into each of the four open holes       |

After the second resume the slicer bridges the holes and prints two solid
layers to encapsulate the magnets. Cross-section showing the embedded pockets:

![cutaway](docs/cutaway.png)

## Render

Requires `openscad` and `just`. Run from this directory:

```sh
just all        # render A-Z as STL pairs (body + outside) into build/ in parallel
just one Q      # render a single letter as an STL pair
just mf3        # render A-Z as combined 3MFs (color-tagged, for dual-extruder)
just one-mf3 Q  # render a single letter as a combined 3MF
just preview Q  # PNG preview (needs an X display)
just clean
```

CI renders all 26 STL pairs on every push and uploads them as the `letter-tags`
workflow artifact.

## Tunables (top of `letter_tag.scad`)

| Param                     | Default                        | Notes                                                                |
| ------------------------- | ------------------------------ | -------------------------------------------------------------------- |
| `layer_height`            | `0.2`                          | Slicer layer height — drives the derived dims                        |
| `letter`                  | `"A"`                          | Override with `-D 'letter="X"'`                                      |
| `font`                    | `"Liberation Sans:style=Bold"` | Any installed font                                                   |
| `letter_size`             | `28`                           | Cap-height target in mm                                              |
| `color_layers`            | `3`                            | Letter-color layers → filament-swap z                                |
| `tile_height`             | `6`                            | Total thickness, base bottom → top face                              |
| `add_magnets`             | `true`                         | Embed 6×2 mm magnet pockets                                          |
| `magnet_d`                | `5.85`                         | Inscribed Ø at bump tips (press dim). Lower = tighter, higher = looser |
| `magnet_h`                | `2.0`                          | Magnet thickness (6×2 mm neodymium)                                  |
| `magnet_pos`              | `13`                           | Center offset from tile center (8 mm from grid edge)                 |
| `magnet_cover_layers`     | `2`                            | Layers between magnet and the baseplate side                         |
| `magnet_clearance_layers` | `1`                            | Extra pocket headroom above the magnet, in layers                    |
| `magnet_bumps`            | `3`                            | Number of press-fit bumps inside the cavity wall                     |
| `magnet_bump_protrusion`  | `0.3`                          | Each bump's radial protrusion (cavity Ø = `magnet_d + 2 × this`)     |
| `magnet_bump_chamfer`     | `0.6`                          | Bump entry chamfer height in mm; eases magnet insertion              |
