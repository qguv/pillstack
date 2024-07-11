include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* command-line parameters */
PNG = !is_undef(PNG);

/* textures */
diamonds = texture("diamonds");

/* [General] */
Diameter = 23; // [23:slim, 33:wide, 46:extrawide]

/* [First cup] */
First_cup_height = 18; // [7:XS, 18:M, 23:L, 25:XL]
First_cup_smooth = false;

/* [Second cup] */
Second_cup_height = 23; // [0:none, 7:XS, 18:M, 23:L, 25:XL]
Second_cup_smooth = false;

/* [Third cup] */
Third_cup_height = 7; // [0:none, 7:XS, 18:M, 23:L, 25:XL]
Third_cup_smooth = true;

/* [Fourth cup] */
Fourth_cup_height = 7; // [0:none, 7:XS, 18:M, 23:L, 25:XL]
Fourth_cup_smooth = false;

/* [Cap] */
Cap_smooth = false;
Cap_keychain = false;

function nonzero_first_elements(xs) = [ for (x=xs) if (x[0] != 0) x ];

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
    pitch,
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
    pitch,
    texture=undef,
    tex_size=undef,
    tex_scale=undef
) {
    intersection() {
        cyl(
            d=outer_diameter,
            h=height,
            texture=texture,
            tex_size=tex_size,
            tex_scale=tex_scale,
            anchor=BOTTOM
        );
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
    orig_base_remake(DEBUG_squat=true);
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

function get_h(p) =
    p * sqrt(3) / 2;

function get_d_min(d_maj, p) =
    d_maj - 2 * (5 / 8) * get_h(p);

module cyl_V(
    d,
    d_conn,
    d_base,
    h,
    h_base,
    texture=undef,
    tex_size=undef,
    tex_scale=undef
) {

    // vessel
    translate([0, 0, h_base])
        cyl(
            d=d,
            h=h,
            texture=texture,
            tex_size=tex_size,
            tex_scale=tex_scale,
            anchor=BOTTOM
        );

    // base
    cylinder(d2=d_conn, d1=d_base, h=h_base);
}

module cupje(
    d,
    d_inner,
    h, // includes bottom wall
    d_conn,
    h_base, // includes base wall
    d_base,
    wall,
    texture=undef,
    tex_size=undef,
    tex_scale=undef
) {
    difference() {

        base_slope = atan2((d_conn - d_base) / 2, h_base);
        echo("base slope", base_slope);
        outer_slope = (base_slope + 90) / 2;
        d_inner_diff = 1 / (tan(outer_slope) * wall);
        d_base_inner = d_base - 2 * d_inner_diff;
        h_taper = ((d_inner - d_base_inner) / 2) / tan(base_slope);

        // outer
        cyl_V(
            d=d,
            h=h,
            d_conn=d_conn,
            h_base=h_base,
            d_base=d_base,
            texture=texture,
            tex_size=tex_size,
            tex_scale=tex_scale
        );

        // inner taper
        translate([0, 0, wall])
            cylinder(d1=d_base_inner, d2=d_inner, h=h_taper);

        // inner
        translate([0, 0, wall + h_taper])
            cylinder(d=d_inner, h=h + h_base - wall - h_taper + 1);
    }
}

module base(
    outer_height,
    outer_diameter=23,
    mating_height=2.5,
    pitch=2,
    wall=1,
    extra_female_mating_height=1,
    extra_outer_wall=0,
    extra_inner_wall=0,
    texture=undef,
    tex_size=[2, 2],
    tex_scale=0.2
) {
    thread_major_diameter = outer_diameter - 2 * wall - 2 * extra_outer_wall;
    inner_height = outer_height - 2 * mating_height - extra_female_mating_height - wall;
    echo("inner height", inner_height);

    thread_minor_diameter = get_d_min(thread_major_diameter * 2, pitch) / 2;
    inner_diameter = thread_minor_diameter - 2 * wall - 2 * extra_inner_wall;
    echo("thread major diameter", thread_major_diameter);
    echo("thread minor diameter", thread_minor_diameter);
    echo("inner diameter", inner_diameter);

    if (outer_height > 0) {
        translate([0, 0, outer_height - mating_height])
            base_male_threads(
                thread_major_diameter=thread_major_diameter,
                inner_diameter=inner_diameter,
                height=mating_height,
                pitch=pitch
            );

        // body
        core_height = outer_height - 2 * mating_height - extra_female_mating_height; // includes bottom wall
        echo("core height", core_height);
        cupje(
            d=outer_diameter,
            d_inner=inner_diameter,
            d_conn=inner_diameter - 2 * get_slop(),
            d_base=inner_diameter - 2 * get_slop() - 2 * wall,
            wall=wall,
            h=core_height,
            h_base=mating_height + extra_female_mating_height,
            texture=texture,
            tex_scale=tex_scale,
            tex_size=tex_size
        );
    } else {
        translate([0, 0, mating_height + extra_female_mating_height]) {
            cyl(
                d1=outer_diameter,
                d2=outer_diameter - 2 * wall,
                h=wall,
                anchor=BOTTOM
            );
        }
    }

    base_female_threads(
        thread_major_diameter=thread_major_diameter,
        outer_diameter=outer_diameter,
        height=mating_height + extra_female_mating_height,
        pitch=pitch,
        texture=texture,
        tex_scale=tex_scale,
        tex_size=tex_size
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

module techno_visuals() {
    cupje(
        d=20,
        d_base=10,
        h=20,
        h_base=10,
        wall=1
    );
}

module compare_thread_scaling() {
    orig_base_remake(0.7174);
    translate([0, 0, 10])
        scale([1, 1, 1] * 0.7174)
            orig_base_remake();
}

module orig_base_remake(virtual_scale=1, DEBUG_squat=false) {
    base(
        outer_diameter=46,
        outer_height=25 - (DEBUG_squat ? 14.5 : 0),
        mating_height=3.5 * virtual_scale,
        pitch=3 * virtual_scale,
        extra_female_mating_height=1.5,
        extra_outer_wall=2.3197,
        extra_inner_wall=0.0565024
    );
}

module base_keychain(
    outer_diameter=23,
    mating_height=2.5,
    wall=1,
    extra_female_mating_height=1,
    texture=undef,
    tex_size=[2, 2],
    tex_scale=0.2
) {
    height = outer_diameter / 2;
    translate([
        0,
        0,
        mating_height + extra_female_mating_height + wall
    ]) {
        difference() {
            top_half() rotate([0, 90, 0]) sphere(d=height, anchor=CENTER);
            rotate([0, 90, 0]) cylinder(d=height / 2, h=height * 2, anchor=CENTER);
        }
    }

    base(
        0,
        texture=texture,
        tex_size=tex_size,
        tex_scale=tex_scale
    );
}

function range(x) = is_list(x) ? [0 : len(x)-1] : [0 : x-1];

function accumulate(xs) = [ for (
        i=0, sum=0;
        i <= len(xs);
        sum = sum + (i < len(xs) ? xs[i] : 0), i = i + 1
) sum ];

module stack(heights, is_smooths, diameter=23) {

    aheights = accumulate(heights);

    // translation to apply to every element
    base_translation = PNG ? [0, 0, 0] : [0, diameter/2, 0];

    // translation factor for each element to account for the cumulative *height* of previous elements
    height_factor = PNG ? [0, 0, 1] : [0, 0, 0];

    // translation factor for each element to account for the *number* of previous elements (irrespective of height)
    count_factor = (PNG ? [0, 0, 0] : [0, diameter, 0]);

    // add space between the elements
    padding = (PNG ? [0, 0, -2.5] : [0, 5, 0]);

    height_translations = [ for (n = aheights) n * height_factor ];
    count_translations = [ for (i = range(aheights)) i * count_factor ];
    padding_translations = [ for (i = range(heights)) i * padding ];

    size = last(height_translations) + last(count_translations) + last(padding_translations);
    center_translation = -size / 2;

    for (i=[0:len(heights)-1]) {
        texture = is_smooths[i] ? undef : diamonds;
        colorname = is_smooths[i] ? "#27f" : undef;
        height = heights[i];
        flipcap = !PNG && height == 0;
        start = (
            base_translation
            + height_translations[i]
            + count_translations[i]
            + padding_translations[i]
            + center_translation
        );

        translate(start)
        rotate([flipcap ? 180 : 0, 0, 0])
        color(colorname)
        base(height, diameter, texture=texture);
    }
}

module all() {
    cups = [
        [First_cup_height, First_cup_smooth],
        [Second_cup_height, Second_cup_smooth],
        [Third_cup_height, Third_cup_smooth],
        [Fourth_cup_height, Fourth_cup_smooth]
    ];

    // pull out nonzero heights and corresponding is_smooths
    heights = [ for (cup=cups) if (cup[0] != 0) cup[0] ];
    is_smooths = [ for (cup=cups) if (cup[0] != 0) cup[1] ];

    // add cap
    if (Cap_keychain) {
        translate([-30, 0, 0]) rotate([PNG ? 0 : 180, 0, 0]) base_keychain(Diameter, texture=diamonds);
        stack(heights, is_smooths, Diameter);

    } else {
        heights = concat(heights, [0]);
        is_smooths = concat(is_smooths, [Cap_smooth]);
        stack(heights, is_smooths, Diameter);
    }
}

$vpd = 250;
$fn=(PNG || !$preview) ? 90 : 20;
$slop = 0.2;

all();
