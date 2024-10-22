// Cap inner radias
cap_inner_r_user = 45.50;
// number of wall shells
shells = 2;
// cap top thickness
cap_thickness_user = 2;
// cap lip, from inner cap to edge of lip
cap_lip_user = 14; 
// handle width
handle_width = 25;
// Handle length
handle_length = 20;
// handle thickness
handle_thickness = 2;
// handle bevel location in percent of length
handle_bevel = 0.75;
// nozzle width
nozzle_width = 0.4;
// layer thickness
layer = 0.3;



$fn= $preview? 32:180;
$fa=.1;

use <../libs/Round-Anything/polyround.scad>
// Optimize for nozzel and layer height
cap_thickness = floor(cap_thickness_user / layer) * layer;
echo(cap_thickness);
cap_inner_r = floor(cap_inner_r_user / nozzle_width) * nozzle_width;
echo(cap_inner_r);
cap_lip = floor(cap_lip_user / layer) * layer;
wall_thickness = shells * nozzle_width;

// Gnerates a cap
// r: radius to the inner lip
// h: height of the inner lip
// wt: wall thickness 
// bt: Base thickness
module cap(r=cap_inner_r, h=cap_lip, wt=wall_thickness, bt=cap_thickness) {
    difference() {
        cylinder(r=r+wt, h=h+bt);
        translate([0,0,bt])cylinder(r=r,h=h);
    }
}

// creates a handle for the cap
// r: radius of the innter part of the handle
// l: length of the handle
// w: width of the handle
// h: height of the handle filet
// t: thickness of the handle
// f: fillet location in % of handle length
module handle(w, l, r, h, t, f) {
    rl = r+l;
    assert(f <= 1 && f >= 0);
    rl_bevel = ((1-f) * l) + r;
    echo(rl_bevel);
    t2 = (h-t)*(1-f);
    echo(t2);
    // 1 ------------2 
    //  |   4______ ) 3
    //  |  /
    // 7|/6
    points = [
        [r, 0, 0],
        [rl, 0, .5],
        [rl, t, .5],
        [rl_bevel, t2, 3],
        [r, h, 0],
        [r, 0, 0]
    ];
    angle=2*asin(w/(2*rl));
    rotate_extrude(angle=angle)
        polygon(polyRound(points));
}

union() {
    cap();
    handle(w = handle_width, l = handle_length, r = cap_inner_r+wall_thickness, h = cap_lip+cap_thickness, t = handle_thickness, f = handle_bevel);
}
