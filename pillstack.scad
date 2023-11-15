// animation: fix camera in place
//$vpr = [$vpr[0], 0, $vpr[2]];
//$vpt = [0, 0, 0];

// animation: spin
//$vpr = [$vpr[0], 0, 360 * $t];

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

// 46d 25h
module orig_base() {
    rotate([0, 0, 142])
        translate([0, 0, 12.5])
            import("lib/base.stl");
}

// 46d 9h
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

module pip_orig_base() {
    union() {
        orig_base();
        translate([0, 0, -11])
            pips(20);
    };
}

module pip_orig_cap() {
    union() {
        orig_cap();
        translate([0, 0, -1])
            pips(6);
    };
}

module base_male_threads(
    thread_major_diameter,
    inner_diameter,
    height,
    pitch
) {
    rotate([0, 0, 180]) {
        difference() {
            threaded_rod(
                d=thread_major_diameter,
                l=height,
                pitch=pitch,
                blunt_start=false,
                bevel=false,
                anchor=BOTTOM
            );
            translate([0, 0, -1]) cylinder(d=inner_diameter, h=height + 2);
        }
    }
}

module base_female_threads(
    thread_major_diameter,
    outer_diameter,
    height,
    pitch
) {
    intersection() {
        cylinder(d=outer_diameter, h=height);
        threaded_nut(
            nutwidth=outer_diameter+10,
            id=thread_major_diameter,
            h=height,
            pitch=pitch,
            blunt_start=false,
            ibevel=false,
            bevel=false,
            anchor=BOTTOM
        );
    }
}

module test_sanity_print() {
    base(outer_height=25 - 14.5);
}

module test_fit(
    outer_diameter=46,
    mating_height=3.5,
    wall=1,
    pitch=3,
    extra_female_mating_height=1.5,
    extra_outer_wall=2.3197,
) {
    thread_major_diameter = outer_diameter - 2 * wall - 2 * extra_outer_wall;

    xz_slice() {

        base_female_threads(
            thread_major_diameter=thread_major_diameter,
            outer_diameter=outer_diameter,
            height=mating_height + extra_female_mating_height,
            pitch=pitch
        );

        translate([0, 0, -0.75])
            base_male_threads(
                thread_major_diameter=thread_major_diameter,
                inner_diameter=0,
                height=mating_height,
                pitch=pitch
            );
    }
}

function d_min(d_maj, p) =
    d_maj - (5 * sqrt(3) / 8) * p;

module cyl_V(d, d_conn, d_base, h, h_base) {

    // vessel
    translate([0, 0, h_base])
        cylinder(d=d, h=h);

    // base
    cylinder(d2=d_conn, d1=d_base, h=h_base);
}

module cupje(d, d_conn, d_base, h, h_base, wall) {
    difference() {

        d_inner = d - 2 * wall;
        d_conn_inner = d_conn - (wall * (d_conn - d_base) / (2 * h_base));
        d_base_inner = d_base - d_conn + d_conn_inner;

        // outer
        cyl_V(
            d=d,
            d_conn=d_conn,
            d_base=d_base,
            h=h,
            h_base=h_base - wall
        );

        // inner
        translate([0, 0, wall])
            cyl_V(
                d=d_inner,
                d_base=d_base_inner,
                h=h - wall,
                h_base=h_base
            );
    }
}

module base(
    outer_diameter=46,
    outer_height=25,
    mating_height=3.5,
    wall=1,
    pitch=3,
    extra_female_mating_height=1.5,
    extra_outer_wall=2.3197,
    extra_inner_wall=0.0565024
) {
    thread_major_diameter = outer_diameter - 2 * wall - 2 * extra_outer_wall;
    inner_height = outer_height - 2 * mating_height - extra_female_mating_height - wall;
    echo("inner height", inner_height);

    thread_minor_diameter = d_min(thread_major_diameter, pitch);
    inner_diameter = thread_minor_diameter - 2 * wall - 2 * extra_inner_wall;
    echo("thread major diameter", thread_major_diameter);
    echo("thread minor diameter", thread_minor_diameter);
    echo("inner diameter", inner_diameter);

    translate([0, 0, DEBUG_explode ? 5 : 0])
    translate([0, 0, outer_height - mating_height])
        base_male_threads(
            thread_major_diameter=thread_major_diameter,
            inner_diameter=inner_diameter,
            height=mating_height,
            pitch=pitch
        );

    // body
    core_height = outer_height - 2 * mating_height - extra_female_mating_height;
    echo("core height", core_height);
    /*
    translate([0, 0, mating_height + extra_female_mating_height])
        difference() {
            cylinder(
                d=outer_diameter,
                h=core_height
            );
            translate([0, 0, wall])
                cylinder(
                    d=inner_diameter,
                    h=core_height - wall + 1
                );
        }
    */
    cupje(
        d=outer_diameter,
        d_conn=outer_diameter * 2 / 3,
        d_base=outer_diameter / 3,
        wall=wall,
        h=core_height,
        h_base=mating_height + extra_female_mating_height + wall
    );

    translate([0, 0, DEBUG_explode ? -5 : 0])
    base_female_threads(
        thread_major_diameter=thread_major_diameter,
        outer_diameter=outer_diameter,
        height=mating_height + extra_female_mating_height,
        pitch=pitch
    );
}

module test_pitch() {
    translate([0, 0, 21.72])
    cylinder(d=46 - 2 * 1 - 2 * 2.3197 + 0.1, h=3);
}

module xz_slice() {
    rotate([-90, 0, 0])
        projection(cut=true)
            rotate([90, 0, 0])
                children();
}

module all() {
    base();
}

$fn=90;
$slop = 0.1;

DEBUG_explode = true;

//orig_base();
//test_fit();
//test_sanity_print();
xz_slice() // DEBUG
base();
/*
base(
    outer_diameter=23,
    outer_height=33 - (24.5 - 20.5),
    mating_height=3.5,
    wall=1,
    pitch=3,
    extra_female_mating_height=0.5,
    extra_outer_wall=0,
    extra_inner_wall=0
);
*/

module techno_visuals() {
    cupje(
        d=20,
        d_base=10,
        h=20,
        h_base=10,
        wall=1
    );
}
