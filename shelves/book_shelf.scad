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
shelf_thickness = 20;
// How wide should it be? 
shelf_width = 150; 
// How thick should the support be? 
support_thickness = 6; // mm
// nozzle width
nozzle = 0.4;

///////////////////////////// Internal //////////////////////////////

$fn= $preview? 32:180;
$fa=.1;
version = "v1.0";
size = str(book_depth," mm");


// TODO: add version emboss
// TODO: add size emboss

// The base is the size of the book + some wall thickness + the distance 
// between the book and the wall when the book is tilted backwards

// From back of the book to the wall is book_thickness * sin (book_angle)
// shelf_width = num_books * (book_width + book_spacing) + wall_thickness*2; 
wall_to_book = book_height * sin(slot_angle);
shelf_depth = wall_to_book + book_depth + wall_thickness;  
support_height = screw_head_dia * 2; // make it tall enough to support the screws.  

module angle_cutter(right = true) {
c = sqrt(pow(support_height,2) + pow(shelf_width/4, 2));
theta = asin(support_height/c);
translate(v = [right? shelf_width/2:-shelf_width/2, -shelf_depth/2,shelf_depth/2+support_height]) 
rotate(a = [0, right? theta:-theta, 0]) 
cube(size = [shelf_width/2, support_thickness*2, support_height*2], center = true);
}

module counter_sunk_screw(sink_depth = 3, head_dia = 8, hole_dia = 5, l = 10) {
    cylinder(h = sink_depth, r = head_dia/2);
    cylinder(h = l, r = hole_dia/2);
}

module chamfer(w = 1, l = 1) {
    linear_extrude(height = w, center = true)polygon(points = [[0,0], [0,l], [l,0]]); 
}


use <MCAD/boxes.scad> 
// use <MCAD/boxes.scad>
// Create the shelf
difference() {

union() {
difference() {
    // Main shelf
    // cube([shelf_width, shelf_depth, shelf_thickness], center = true);
    roundedCube([shelf_width, shelf_depth, shelf_thickness], r=2, sidesonly=true,center=true); // Adding a bit of clearance

    // Slot for the book
    rotate([-slot_angle, 0, 0])
    translate([0, book_depth/2 - wall_thickness, -((book_depth/2*sin(slot_angle))+wall_thickness)])
    // cube([(book_width + book_spacing), book_depth, (shelf_thickness-wall_thickness)], center=true); // Adding a bit of clearance
    roundedCube([(book_width + book_spacing), book_depth, (shelf_thickness-wall_thickness)], r=2, sidesonly=false,center=true); // Adding a bit of clearance
};

difference() {
// Add support panel
translate(v = [0,-shelf_depth/2+support_thickness/2, support_height/2]) 
    cube([shelf_width, support_thickness, support_height+shelf_thickness], true);
    // roundedCube([shelf_width, support_thickness, support_height], r=support_thickness/2, sidesonly=true, center=true);
// Cut off the sides of the support
angle_cutter(true);
angle_cutter(false);
// Add counter sunk holes
for (n = [-1:2:1]){
translate([n*shelf_width/4, -(shelf_depth/2-support_thickness-0.1), shelf_thickness/2+support_height/2]) rotate([90,0,0]) 
counter_sunk_screw(sink_depth = screw_head_depth, hole_dia = screw_diameter, head_dia = screw_head_dia, l = support_thickness*2);
}
}
// Add rib
translate(v = [0,-(shelf_depth/2-support_thickness),shelf_thickness/2]) 
rotate(a = [0,-90,0]) 
linear_extrude(height = support_thickness) 
polygon(points = [[0,0], [0, shelf_depth-support_thickness], [support_height, 0]], paths = [[0,1,2]]);

// Chamfer support to shelf
translate([0,-shelf_depth/2+support_thickness,shelf_thickness/2])rotate([90,0,0])rotate([0,90,0])chamfer(shelf_width, screw_head_dia/3);
}

translate([shelf_width/2-wall_thickness,-(shelf_depth/2-nozzle_width),0]) rotate([90,180,0])linear_extrude(nozzle_width)text(text = version, size = 5);
translate([0,-(shelf_depth/2-nozzle_width),0]) rotate([90,180,0])linear_extrude(nozzle_width)text(text = size, size = 5);
}

/// the chatgpt response
// // Shelf dimensions
// shelf_width = 250; // Adjust as needed
// shelf_depth = 200; // Adjust as needed
// shelf_thickness = 15;

// // Book dimensions
// book_width = 205;
// book_depth = 15; // Swap depth and height for standing on end
// book_height = 205; // Swap depth and height for standing on end

// // Slot angle
// slot_angle = 5;

// // Screw dimensions
// screw_diameter = 4; // Assuming #8 screws

// // Support plate dimensions
// plate_thickness = 5;

// // Create the shelf and support structure
// difference() {
//     union() {
//         // Main shelf
//         cube([shelf_width, shelf_depth, shelf_thickness]);

//         // Slot for the book
//         translate([shelf_width/2, shelf_depth/2, 0])
//         rotate([slot_angle, 0, 0])
//         translate([-book_width/2, -book_depth/2, 0])
//         cube([book_width, book_depth, shelf_thickness + 2]); // Adding a bit of clearance
//     }

//     // Support structure below the shelf
//     translate([shelf_width/2, shelf_depth/2, -shelf_thickness])
//     cube([shelf_width, shelf_depth, shelf_thickness]);

//     // Ribs for additional support
//     for (i = [1, -1])
//         for (j = [1, -1])
//             translate([i * (shelf_width/4), j * (shelf_depth/4), -shelf_thickness])
//             cube([shelf_thickness, shelf_thickness, shelf_thickness]);

//     // Support plate below the small shelf
//     translate([shelf_width/2, shelf_depth/2, -shelf_thickness - plate_thickness])
//     cube([shelf_width, shelf_depth, plate_thickness]);

//     // Screw holes
//     for (i = [1, -1])
//         for (j = [1, -1])
//             translate([i * (shelf_width/4), j * (shelf_depth/4), -1])
//             rotate([90, 0, 0])
//             cylinder(h = shelf_thickness + plate_thickness + 4, d = screw_diameter, $fn = 6);
// }



