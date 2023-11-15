// animation: fix camera in place
//$vpr = [$vpr[0], 0, $vpr[2]];
//$vpt = [0, 0, 0];

// animation: spin
//$vpr = [$vpr[0], 0, 360 * $t];

scale_incoming = 33 / 46;
scale_outgoing = 1;

module orig_base() {
    rotate([90, 0, 0])
        scale([scale_incoming, scale_incoming, scale_incoming])
            import("lib/[PLA][v1.0] Stackable_C_Base.3mf");
}

module orig_cap() {
    rotate([270, 0, 0])
        scale([scale_incoming, scale_incoming, scale_incoming])
            import("lib/[PLA][v1.0] Stackable_C_Cap.3mf");
}

module pips(h, r=22.9, ring_sep=2, n=26) {
    rings = floor(h / ring_sep);
    for (j = [0:rings-1]) {
        for (i = [0:n-1]) {
            maybe_half_steps = j % 2 ? 0.5 : 0;
            rotate([0, 0, (i + 1/8 + maybe_half_steps) * 360 / n])
                translate([r, 0, j * ring_sep])
                    pip();
        }
    }
}

module pip() {
    $fn=6;
    rotate([0, 90, 0])
    cylinder(h=1.5, r1=0.7, r2=0);
}

module base() {
    union() {
        orig_base();
        translate([0, 0, -11])
            pips(20);
    };
}

module cap() {
    union() {
        orig_cap();
        translate([0, 0, -1])
            pips(6);
    };
}

module all() {
    sep = 30;
    translate([-sep, 0, 0]) base();
    translate([sep, 0, 0]) cap();
}

all();
