// Gridfinity-compatible 1x1 letter tag.
//
// Two-material design for a dual-extruder / IDEX printer. The top face is
// perfectly flush: the `body` part contains the Gridfinity base, the letter
// (extending to the top face), and the surrounding tile up to color_layers
// below the top; the `outside` part is a thin cap that fills the top
// color_layers around the letter. The two parts mate on coplanar surfaces,
// so the slicer assigns each to a different extruder and prints them
// simultaneously — no filament swap.
//
// Print upside down (top face on the build plate). The outside cap is laid
// down first; the body continues above it. Four 6x2 mm magnets are embedded
// in standard Gridfinity corner positions; pause at z = tile_height -
// magnet_ceiling to drop them in, then resume to bridge over.
//
// Render both parts:
//   openscad -o A_body.stl    -D 'letter="A"' -D 'part="body"'    letter_tag.scad
//   openscad -o A_outside.stl -D 'letter="A"' -D 'part="outside"' letter_tag.scad
//
// Override `letter` from the command line:
//   openscad -o A.stl -D 'letter="A"' letter_tag.scad

/* [Print] */
layer_height = 0.2;    // slicer layer height; everything important is in layers
part         = "all";  // "all" (preview), "body", or "outside"

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

module raw_tile() {
    gf_base();
    translate([0, 0, gf_base_h])
        linear_extrude(tile_height - gf_base_h)
            rounded_square(gf_outer, gf_outer_r);
}

// Top color_layers slab in the tile silhouette, with the letter cut out.
// `extra` extends the top face upward for clean boolean subtraction.
module outside_cap(extra=0) {
    translate([0, 0, tile_height - recess_depth])
        linear_extrude(recess_depth + extra)
            difference() {
                rounded_square(gf_outer, gf_outer_r);
                text(letter, size=letter_size, font=font,
                     halign="center", valign="center");
            }
}

module body() {
    difference() {
        raw_tile();
        outside_cap(extra=0.1);
        if (add_magnets) magnet_pockets();
    }
}

module outside() {
    outside_cap();
}

// Preview-only colors; ignored by STL export.
body_color    = "WhiteSmoke";
outside_color = "Crimson";

if (part == "all") {
    color(body_color)    body();
    color(outside_color) outside();
} else if (part == "body") {
    color(body_color) body();
} else if (part == "outside") {
    color(outside_color) outside();
} else {
    assert(false, str("Unknown part: ", part, " (expected \"all\", \"body\", or \"outside\")"));
}
