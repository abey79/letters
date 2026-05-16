// Gridfinity-compatible 1x1 letter tag.
//
// Designed to be printed upside down (letter face on the build plate) with a
// filament swap at z = recess_depth, producing a flat top:
//   - The letter sits at the original top plane.
//   - The background is recessed by recess_depth (default 0.6 mm = 3 layers at 0.2 mm).
//   - Layers below the swap print only the letter shape -> letter color.
//   - Layers above fill in the rest of the tile         -> background color.
//
// Magnets (6 x 2 mm) are embedded in the four standard Gridfinity corner
// positions and encapsulated by a 2-layer ceiling. Because we print upside
// down, the pockets open *upward* during the print: add a second pause in
// your slicer at z = tile_height - magnet_ceiling (= 5.6 mm with defaults),
// drop the four magnets into the open holes, resume. The next layer bridges
// 6.5 mm cleanly.
//
// Override `letter` from the command line:
//   openscad -o A.stl -D 'letter="A"' letter_tag.scad

/* [Letter] */
letter        = "A";
font          = "Liberation Sans:style=Bold";
letter_size   = 28;    // cap-height target in mm

/* [Tile] */
tile_height   = 6;     // total tile thickness, base bottom -> top face
recess_depth  = 0.6;   // total height of the letter-color layers (e.g. 3 x 0.2 mm)

/* [Magnets] */
add_magnets    = true;
magnet_d       = 6.5;  // hole diameter; canonical loose fit (glue) per kennetek
magnet_h       = 2.0;  // 6 x 2 mm neodymium magnet thickness
magnet_pos     = 13;   // center offset from tile center (= 8 mm from 42 mm grid edge)
magnet_ceiling = 0.4;  // plastic between magnet and baseplate (2 layers @ 0.2 mm)

/* [Gridfinity 1x1 base, official spec] */
gf_outer      = 41.5;
gf_outer_r    = 3.75;
gf_chamfer_lo = 0.8;
gf_straight   = 1.8;
gf_chamfer_hi = 2.15;
gf_base_h     = gf_chamfer_lo + gf_straight + gf_chamfer_hi;   // 4.75

$fa = 2;
$fs = 0.3;

module rounded_square(size, r) {
    offset(r=r) offset(r=-r) square(size, center=true);
}

module gf_base() {
    bottom   = gf_outer  - 2 * (gf_chamfer_lo + gf_chamfer_hi);   // 35.6
    bottom_r = gf_outer_r -      gf_chamfer_lo - gf_chamfer_hi;   // 0.8
    mid      = gf_outer  - 2 *  gf_chamfer_hi;                    // 37.2
    mid_r    = gf_outer_r -      gf_chamfer_hi;                   // 1.6

    // Lower chamfer
    hull() {
        linear_extrude(0.01) rounded_square(bottom, bottom_r);
        translate([0, 0, gf_chamfer_lo - 0.01])
            linear_extrude(0.01) rounded_square(mid, mid_r);
    }
    // Straight middle
    translate([0, 0, gf_chamfer_lo])
        linear_extrude(gf_straight) rounded_square(mid, mid_r);
    // Upper chamfer
    translate([0, 0, gf_chamfer_lo + gf_straight]) hull() {
        linear_extrude(0.01) rounded_square(mid, mid_r);
        translate([0, 0, gf_chamfer_hi - 0.01])
            linear_extrude(0.01) rounded_square(gf_outer, gf_outer_r);
    }
}

module magnet_pockets() {
    // Pockets are encapsulated: magnet_ceiling of solid plastic sits between
    // the magnet and the base bottom (the face touching the baseplate).
    for (sx = [-1, 1]) for (sy = [-1, 1])
        translate([sx * magnet_pos, sy * magnet_pos, magnet_ceiling])
            cylinder(h = magnet_h + 0.1, d = magnet_d);
}

module tile() {
    difference() {
        union() {
            gf_base();
            translate([0, 0, gf_base_h])
                linear_extrude(tile_height - gf_base_h)
                    rounded_square(gf_outer, gf_outer_r);
        }
        // Carve the top: subtract a (big square) minus (letter), leaving
        // the letter at full height and the rest recessed by recess_depth.
        translate([0, 0, tile_height - recess_depth])
            linear_extrude(recess_depth + 0.1)
                difference() {
                    square(gf_outer + 2, center=true);
                    text(letter, size=letter_size, font=font,
                         halign="center", valign="center");
                }
        if (add_magnets) magnet_pockets();
    }
}

tile();
