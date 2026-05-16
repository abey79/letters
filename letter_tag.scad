// Gridfinity-compatible 1x1 letter tag.
//
// Designed to be printed upside down (letter face on the build plate) with a
// filament swap after the first layer, producing a perfectly flat top:
//   - The letter sits at the original top plane.
//   - The background is recessed by exactly one layer (recess_depth, default 0.2 mm).
//   - Layer 1 prints only the letter shape  -> letter color.
//   - Layers 2+ fill in the rest of the tile -> background color.
//
// Override `letter` from the command line:
//   openscad -o A.stl -D 'letter="A"' letter_tag.scad

/* [Letter] */
letter        = "A";
font          = "Liberation Sans:style=Bold";
letter_size   = 28;    // cap-height target in mm

/* [Tile] */
tile_height   = 6;     // total tile thickness, base bottom -> top face
recess_depth  = 0.2;   // must match your slicer's first layer height

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
    }
}

tile();
