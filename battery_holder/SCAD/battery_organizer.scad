/*
    Title: Battery Organizer
    Author: lonelycowboy49
    Date: 19/11/2023
    Description: Customisable battery organizer for AAAA, AAA, AA, C, D, 14500, 18650, 21700, 26650, Coin Cell, 4LR44, 3:23A, LR1, CR123A

    License: This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International License.
    To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/4.0/ or send a letter to Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

    You are free to:
    - Share — copy and redistribute the material in any medium or format
    - Adapt — remix, transform, and build upon the material for any purpose, even commercially.

    Under the following terms:
    - Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. 
      You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
    - ShareAlike — If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.

    This code is provided "as is", without warranty of any kind, express or implied.

    Instructions:
        Set up parameters, render and print.
        
    Version History:
    - 0.1 (2023-11-02): Initial version.
    - 1.0 (2023-12-02): Initial release.
*/
$fn = $preview ? 15 : 90;

/* [Battery type] */ 
// the battery type based on type, or enter correct diameter in mm below
battery_type = 14.5; // [8.3:AAAA Battery, 10.5:AAA Battery, 14.5:AA Battery, 26.2:C Battery, 34.2:D Battery, 14:14500 Battery, 18:18650 Battery, 21:21700 Battery, 26:26650 Battery, 20:Coin Cell, 13:4LR44 Battery, 10.3:23A Battery, 12:LR1 (N-Size), 17:CR123A, 0:Manual]
// height of the battery storage
storage_h = 16; 
// height of the base (in mm)
base_h = 0.8; 

/* [Grid dimensions] */ 
// number of columns
num_col = 3;
// number of lines
num_lin = 3;
// the thickness of the wall based on the nozzle size
wall_thickness = 0.4; 

/* [Manual override] */
// diameter of the battery (in mm), be sure to select "Manual" above in case you want to use it
battery_d = 0; 
// insertion gap for the batteries to allow smooth insertion (in mm)
insertion_gap = 0.2;
// define the space between the batteries
gap_between_batteries = 2; 

/* [Vase mode] */
// printing in vase mode
vase = true;

// Calculate the diameter based on the entry parameters
diameter = ( battery_type == 0 ) ? ( battery_d + insertion_gap) : (battery_type + insertion_gap);

// Calculate the width of 1 battery unit
unit_w = diameter  + gap_between_batteries;

// Calculate the rounding of the corners
box_offset = (diameter / 2) + wall_thickness * 2;

difference() {
    // Battery storage square
    linear_extrude(base_h + storage_h ) {
        offset(r = box_offset) {
            square([
                (num_lin - 1) * (unit_w),
                (num_col - 1) * (unit_w)
            ]);
        }
    }
    // Remove battery's and connecting pieces
    for (y = [0:num_col - 1]) {
        for (x = [0:num_lin - 1]) {
            translate([unit_w * x, unit_w * y, base_h]) {
                // Remove battery space
                cylinder(storage_h + 1, d=diameter, false);
                // Remove connectors space for printing in vase mode
                if(vase == true) {
                    // Connect corner piece
                    if (y == 0 && x == 0) {
                        translate([-1, -diameter, 0]) {
                            cube([1, diameter, storage_h + 1]);
                        }
                    }
                    // Connect batteries horizontally
                    if (x < num_lin - 1) {
                        translate([0, -1, 0]) {
                            cube([unit_w, 1, storage_h + 1]);
                        }
                    }
                    // Connect batteries vertically depending on row and column
                    if (((y+1)%2 == 0 && x == 0 && y < num_col - 1) ||
                        ((y%2)== 0 && x == num_lin - 1 && y < num_col - 1)) {
                        translate([-1, 0, 0]) {
                            cube([1, unit_w, storage_h + 1]);
                        }
                    }
                }
            }
        }
    }
}