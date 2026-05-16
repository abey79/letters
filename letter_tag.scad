// Gridfinity-compatible 1x1 letter tag.
//
// Designed to be printed upside down (letter face on the build plate) with a
// filament swap producing a flat 2-color top, and four embedded 6x2 mm
// magnets in the standard Gridfinity corner positions.
//
// Two slicer pauses are needed (defaults shown for 0.2 mm layer height):
//   z = 0.6 mm: filament swap, letter color -> background color
//   z = 5.6 mm: drop a magnet into each of the 4 open holes
// After the second resume the slicer bridges 6.5 mm and prints
// magnet_cover_layers solid layers on top.
//
// Override `letter` from the command line:
//   openscad -o A.stl -D 'letter="A"' letter_tag.scad

/* [Print] */
layer_height = 0.2;    // slicer layer height; everything important is in layers

/* [Letter] */
letter       = "A";
font         = "Liberation Sans:style=Bold";
letter_size  = 28;     // cap-height target in mm
color_layers = 3;      // letter-color layers; recess depth = layer_height * this

/* [Tile] */
tile_height  = 6;      // total tile thickness, base bottom -> top face

/* [Magnets] */
add_magnets         = true;
magnet_d            = 6.5;   // hole diameter; canonical loose fit (glue) per kennetek
magnet_h            = 2.0;   // 6 x 2 mm neodymium magnet thickness
magnet_pos          = 13;    // center offset from tile center (= 8 mm from 42 mm grid edge)
magnet_cover_layers = 2;     // layers between magnet and baseplate

/* [Gridfinity 1x1 base, official spec] */
gf_outer      = 41.5;
gf_outer_r    = 3.75;
gf_chamfer_lo = 0.8;
gf_straight   = 1.8;
gf_chamfer_hi = 2.15;
gf_base_h     = gf_chamfer_lo + gf_straight + gf_chamfer_hi;   // 4.75

// Derived
recess_depth   = layer_height * color_layers;
magnet_ceiling = layer_height * magnet_cover_layers;

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
