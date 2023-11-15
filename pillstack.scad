// animation: fix camera in place
//$vpr = [$vpr[0], 0, $vpr[2]];
//$vpt = [0, 0, 0];

// animation: spin
//$vpr = [$vpr[0], 0, 360 * $t];

scale_factor = 33 / 46;

module orig_base() {
    import("lib/base.stl");
}

module orig_cap() {
    import("lib/cap.stl");
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
    translate([sep, sep, 0]) base();
    translate([sep, -sep, 0]) base();
    translate([-sep, sep, 0]) base();
    translate([-sep, -sep, 0]) orig_base();
    translate([sep, 3*sep, 0]) cap();
}

scale([scale_factor, scale_factor, scale_factor]) all();
