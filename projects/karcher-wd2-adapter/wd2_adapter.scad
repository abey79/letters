// Kärcher WD2 hose -> 63mm tool vacuum adapter
// Tool side: slotted with an M3 clamp screw
// WD2 side:  press fit on the 34.3 -> 35.8 hose taper

// ---- WD2 hose taper (measured) ----
wd2_tip_d        = 34.3;   // narrow end of hose
wd2_base_d       = 35.8;   // wide end
wd2_taper_len    = 50;
wd2_interference = 0.10;   // socket ID undersize for press fit

// ---- Tool port (62.5-63.2 over 16mm) ----
tool_d_max       = 63.2;
tool_clearance   = 0.30;   // pre-clamp slip fit
tool_socket_len  = 22;     // a bit longer than the 16mm port

// ---- Walls / transition ----
wall             = 3;
tool_wall        = 4;      // thicker because it is slotted
transition_len   = 18;

// ---- Clamp ----
slot_w           = 2.5;
slot_overshoot   = 4;      // slot reaches past socket into transition
screw_d          = 3.4;    // M3 clearance
nut_af           = 5.5;    // M3 hex across-flats
nut_thk          = 2.4;
boss_thk         = 10;     // radial extent of each boss
boss_w           = 10;     // tangential width
boss_overlap     = 1;      // sinks into the cylinder

$fn = 120;

// ---- Derived ----
tool_id      = tool_d_max + tool_clearance;
tool_od      = tool_id + 2 * tool_wall;
wd2_tip_id   = wd2_tip_d  - wd2_interference;
wd2_base_id  = wd2_base_d - wd2_interference;
wd2_tip_od   = wd2_tip_id  + 2 * wall;
wd2_base_od  = wd2_base_id + 2 * wall;

z_trans = tool_socket_len;
z_vac   = z_trans + transition_len;

module body() {
    cylinder(d = tool_od, h = tool_socket_len);
    translate([0, 0, z_trans])
        cylinder(d1 = tool_od, d2 = wd2_base_od, h = transition_len);
    translate([0, 0, z_vac])
        cylinder(d1 = wd2_base_od, d2 = wd2_tip_od, h = wd2_taper_len);
}

module bore() {
    translate([0, 0, -0.1])
        cylinder(d = tool_id, h = tool_socket_len + 0.1);
    translate([0, 0, z_trans - 0.01])
        cylinder(d1 = tool_id, d2 = wd2_base_id, h = transition_len + 0.02);
    translate([0, 0, z_vac - 0.01])
        cylinder(d1 = wd2_base_id, d2 = wd2_tip_id, h = wd2_taper_len + 0.2);
}

module bosses() {
    cx = tool_od / 2 - boss_overlap + boss_thk / 2;
    cz = tool_socket_len / 2;
    for (s = [-1, 1])
        translate([cx, s * (slot_w / 2 + boss_w / 2), cz])
            cube([boss_thk, boss_w, tool_socket_len], center = true);
}

module clamp_cuts() {
    cx = tool_od / 2 - boss_overlap + boss_thk / 2;
    cz = tool_socket_len / 2;

    // Radial slot through cylinder + bosses
    translate([-tool_od / 2 - 1, -slot_w / 2, -0.1])
        cube([tool_od + boss_thk + 2, slot_w, tool_socket_len + slot_overshoot]);

    // Screw clearance along Y
    translate([cx, 0, cz]) rotate([90, 0, 0])
        cylinder(d = screw_d, h = tool_od * 2, center = true);

    // Hex nut trap on -Y face, recessed 0.5mm
    nut_y = -(slot_w / 2 + boss_w) + nut_thk / 2 + 0.5;
    translate([cx, nut_y, cz]) rotate([90, 0, 0])
        cylinder(d = nut_af / cos(30) + 0.3, h = nut_thk + 0.4,
                 $fn = 6, center = true);
}

difference() {
    union() { body(); bosses(); }
    bore();
    clamp_cuts();
}
