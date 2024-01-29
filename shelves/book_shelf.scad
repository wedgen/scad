///////////////////// User Settings /////////////////////////////////

// thickness front to back of the book
book_depth = 12.5;
// How wide is the book, spine to not spine?
book_width = 205;
// How tall is your book
book_height = 205;
// Angle the book sits at in deg
slot_angle = 5;
// of the printer
nozzle_width = 0.4;
// how far apart do you want the books in mm
book_spacing = 5; // mm
// Screw dimensions
screw_diameter = 5; // Assuming #8 screws
// Screw Head Diameter
screw_head_dia = 8.5;
// screw head depth
screw_head_depth = 3;
// Spacing between book and outside of the shelf
wall_thickness = 2; 
// How thick should the shelf be? 
shelf_thickness = 15;
// How wide should it be? 
shelf_width = 150; 
// Where sould support be Top or Bottom? 
support_top = true;
// nozzle width
nozzle = 0.4;

///////////////////////////// Internal //////////////////////////////

$fn= $preview? 32:180;
$fa=.1;
version = "v1.0";
size = str(book_depth," mm");
use <MCAD/boxes.scad> 
use <../libs/Round-Anything/polyround.scad>
// The base is the size of the book + some wall thickness + the distance 
// between the book and the wall when the book is tilted backwards

// From back of the book to the wall is book_thickness * sin (book_angle)
wall_to_book = book_height * sin(slot_angle);
shelf_depth = wall_to_book + book_depth + wall_thickness;  
support_height = screw_head_dia * 2; // make it tall enough to support the screws.  
support_thickness = wall_thickness+screw_head_depth; // mm

// TODO: add support location adjustment
module angle_cutter(right = true, width = 100, height = 10, depth = 5, angle = 5) {
    // calculate angle of 
    c = sqrt(pow(height,2) + pow(width/4, 2));
    theta = asin(height/c);
    rotate(a = [0, right? theta:-theta, 0]) 
    cube(size = [width/2, depth*2, height*2], center = true);
}

module counter_sunk_screw(sink_depth = 3, head_dia = 8, hole_dia = 5, l = 10) {
    cylinder(h = sink_depth, r = head_dia/2);
    cylinder(h = l, r = hole_dia/2);
}

module chamfer(w = 1, l = 1) {
    linear_extrude(height = w, center = true)polygon(points = [[0,0], [0,l], [l,0]]); 
}

module support_panel(thickness = support_thickness, height = support_height, width=shelf_width) {
    r = 25;
    points = [[0,0,0], [width/2,0,0], [width/4, height,r], [-width/4, height, r], [-width/2, 0, 0]];
    difference() {
        //      ---|----
        //     /   |    \
        //     ----|-----
        //        0,0
        // TODO: Try PolyRound to give things a softer feel.  
        rotate([90,0,0])linear_extrude(height = thickness, center = true)polygon(polyRound(radiipoints = points)); 
        translate([0, thickness/2, height/2]) add_screw_holes();
    }
    translate([0,thickness/2,0])
    difference() {
        rotate([0,-90,0])chamfer(w = width, l = height/4);
        translate([0,thickness,0])rotate([90,0,0])linear_extrude(height/3) shell2d(height/4 + 1)polygon(polyRound(radiipoints = points));
    }
}

module add_screw_holes(dia = screw_diameter, head_dia = screw_head_dia, sink = screw_head_depth, width = shelf_width, l = support_thickness, sep = shelf_width/4) {
    for (n = [-1:2:1]){
        translate([n*sep,0, 0]) rotate([90,0,0]) 
        counter_sunk_screw(sink_depth = sink, hole_dia = dia, head_dia = head_dia, l = l+1);
    }
}

module shelf(t = shelf_thickness, d = shelf_depth, w = shelf_width, r = 2, angle = slot_angle, wall = wall_thickness, book_d = book_depth, book_w = book_width) {
    book_distance = ((book_d/2*sin(angle))+wall);
    union() {
        // remove rounding on the back 
        translate([w/2-r/2, d/2-r/2, 0])cube([r,r,t], center = true);
        translate([-w/2+r/2, d/2-r/2, 0])cube([r,r,t], center = true); 
        difference() {
            // Main shelf
            echo(book_distance);
            echo(d);
            roundedCube([w, d, t], r=2, sidesonly=true,center=true); // Adding a bit of clearance
            // Slot for the book
            // todo: check for min shelf size
            rotate([angle, 0, 0])
            translate([0, -(book_d/2 - wall), -book_distance])
            roundedCube([book_w, book_d+2, (t)], r=2, sidesonly=false,center=true); // Adding a bit of clearance
        };
    }
}
module rib() {
    translate(v = [0,-(shelf_depth/2-support_thickness),shelf_thickness/2]) 
    rotate(a = [0,-90,0]) 
    linear_extrude(height = support_thickness) 
    polygon(points = [[0,0], [0, shelf_depth-support_thickness], [support_height, 0]], paths = [[0,1,2]]);
}

module assemble() {
    // combines the support to the shelf
    union() {
        // Create the shelf
        shelf();
    rotate = support_top?180:0;
    height = support_top?-shelf_thickness/2:shelf_thickness/2;
        // Add support panel
        translate([0,shelf_depth/2-support_thickness/2, (support_top?1:-1)*height]) 
        rotate([0,rotate,180])
        support_panel(thickness = support_thickness, height = support_height, width = shelf_width);
        // Add support rib for bottom support, prob not necessary, but kinda cool
        if (support_top == false) {
            rib();
        } 

        }
    }
test = false;
if (!test) {
difference() {
    assemble();
    // Embossed version and cutout size. 
    translate([shelf_width/3,(shelf_depth/2-nozzle_width),0]) 
        rotate([-90,0,0])#linear_extrude(nozzle_width)text(text = version, size = 5);
};
}

////////////////// Tests /////////////////////
// shelf();
// support_panel();
// add_screw_holes();
// angle_cutter();
// counter_sunk_screw();
// chamfer();
