# Kärcher WD2 → 63 mm Tool Adapter

Parametric OpenSCAD adapter that joins a Kärcher WD2 shop-vac hose end to a
tool with a ~63 mm round dust port.

CI renders preview and axial-cutaway PNGs into the `karcher-wd2-adapter`
workflow artifact (`build/docs/preview.png`, `build/docs/cutaway.png`).

- **WD2 side:** female socket, press-fit on the hose's 34.3 → 35.8 mm taper
  over 50 mm.
- **Tool side:** female socket clamped by a single M3 screw across a
  longitudinal slot — permanent install on a 62.5–63.2 mm port.

## Hardware

- 1 × M3 × 20 mm (or 25 mm) cap-head screw
- 1 × M3 hex nut (nut trap captures it)

## Dimensions (in `wd2_adapter.scad`)

| Param              | Default | Notes                                            |
| ------------------ | ------- | ------------------------------------------------ |
| `wd2_tip_d`        | `34.3`  | Hose taper, narrow end                           |
| `wd2_base_d`       | `35.8`  | Hose taper, wide end                             |
| `wd2_taper_len`    | `50`    | Hose taper length                                |
| `wd2_interference` | `0.10`  | Socket undersize for press fit — tune to printer |
| `tool_d_max`       | `63.2`  | Max tool port OD                                 |
| `tool_socket_len`  | `22`    | Engagement on the 16 mm tool port                |
| `transition_len`   | `18`    | Conical reducer between the two sockets          |
| `wall` / `tool_wall` | `3` / `4` | Walls — tool side thicker because slotted    |

## Printing

- **Orientation:** tool socket on the bed, WD2 cone pointing up. No supports
  needed — the WD2 taper is < 1° from vertical.
- **Material:** PETG recommended. ABS/ASA also fine. PLA works but the clamp
  may creep over time.
- **Walls:** 4+ perimeters so suction doesn't deform the tube.

## Tuning the press fit

If the WD2 socket is too loose on your printer, bump `wd2_interference` to
0.2–0.3. If it won't seat, drop to 0.05.

## Render

Requires `openscad` and `just`. Run from this directory:

```sh
just         # render STL + 3MF into build/
just preview # PNG preview
just clean
```
