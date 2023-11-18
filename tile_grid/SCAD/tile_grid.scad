/*
    Title: Tile Grid
    Author: lonelycowboy49
    Date: 15/11/2023
    Description: Customisable tile grid for tile-laying tabletop games such as Carcassonne, Karak, Isle of Skye, Alhambre and many more...

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
    - 0.1 (2023-09-01): Initial version.
    - 1.0 (2023-11-16): Initial release.
*/
$fn = $preview ? 15 : 90;

/* [Tile dimensions] */ 
// Define the width of the tile in mm below
tile_w = 46;   
// Define the length of the tile in mm below
tile_l = 46;   

/* [Grid dimensions] */ 
// number of columns
num_col = 3;
// number of lines
num_lin = 3;

/* [Manual override] */
// height of the base (in mm)
base_h = 1.5;  
// height of the dividers (in mm)
divider_h = 1.5;  
// thicknest of dividers (in mm)
divider_w  = 1.5;
// Insertion gap for the connectors to allow smooth insertion (in mm)
insertion_gap  = 2;

// calculate inner and outer tile dimensions
divider2_w = 2 * divider_w;
divider4_w = 4 * divider_w;
divider8_w = 8 * divider_w;
tile_inner_w = tile_w - divider8_w;
tile_inner_l = tile_l - divider8_w;
tile_outer_w = tile_w + divider_w;
tile_outer_l = tile_l + divider_w;

// calculate tile grid dimensions
grid_w = (tile_outer_w * num_col) + divider_w;
grid_l = (tile_outer_l * num_lin) + divider_w;
grid_h = base_h + divider_h;

union () {
    difference() {
        union(){ 
            // Base of the tile grid
            difference() {
                // full till grid
                grid( 0, 0, 0, grid_w, grid_l, base_h);
                // minus the space that will not be supported
                no_support();
            }    
            // Create the columns stoppers
            difference() {
                for (x = [1:num_col]) 
                    grid( tile_outer_w * x, 0, base_h, divider_w, grid_l, divider_h);    
                for (y = [1:num_lin])
                    grid( 0, tile_outer_l * y + divider4_w - tile_l, base_h, grid_w, tile_inner_l, divider_h);               
            } 
            // Create the line stoppers
            difference() {
                for (y = [1:num_lin])
                    grid( 0, tile_outer_l * y, base_h, grid_w, divider_w, divider_h);  
                for (x = [1:num_col])
                    grid( tile_outer_w * x + divider4_w - tile_w, 0, base_h, tile_inner_w, grid_l, divider_h);
            }
        }
        // Add the Female column connectors
        for (x = [1:num_col])
            connector( (tile_outer_w * x ) - (tile_w / 2), grid_l, "x", divider2_w, 0,  0, tile_w * 0.6, divider2_w);
        // Add the Female line connectors
        for (y = [1:num_lin])
            connector( grid_w, (tile_outer_l * y ) - (tile_l / 2), "y", divider2_w, 1, -1, tile_l * 0.5, divider2_w);
        // Remove horizontal line, a grid thick
        cube([grid_w, divider_w, grid_h]);
        // Remove vertical line, a grid thick
        cube([divider_w,grid_l, grid_h*5]);
    }  
    // Add the missing line stoppers
    for (x = [1:num_col]) {
        // Male connectors
        connector( (tile_outer_w * x ) - (tile_w / 2), 0, "x", divider_w, 0,  0, ( tile_w * 0.6) - insertion_gap, divider2_w);
        // Stoppers on the male connectors
        stopper((tile_outer_w * x ) - (tile_w / 2), 0 , "x", 0,  0, tile_w/8);      
    }     
    // Add the missing columns stoppers
    for (y = [1:num_lin]) {
        // Male connectors
        connector( 0, (tile_outer_l * y ) - (tile_l / 2), "y", divider_w, 1, -1, ( tile_l * 0.5) - insertion_gap, divider2_w);
        // Stoppers on the male connectors
        stopper( 0, (tile_outer_l * y ) - (tile_l / 2), "y", 1, -1, tile_l/8); 
    }  
}
module grid(x, y, z, w, l, h) {
    translate([x, y, z]) {
        cube([w, l, h]);
    }
}
module no_support() {
    for (x=[0:num_col-1]) {
        for (y=[0:num_lin-1]) {
            translate([divider_w + divider4_w + (tile_outer_w * x), divider_w + divider4_w + ( tile_outer_l * y),  0]) 
                linear_extrude(height = grid_h) offset(r=divider2_w) square([tile_inner_w, tile_inner_l] );
        }
    }
}
module stopper(x_center, y_center, adjust, x_mirror, y_mirror, width) {
    // Correct x and y coordinates to adjust for the centering
    x = ( adjust == "x" ) ? x_center - width / 2 : x_center;
    y = ( adjust == "y" ) ? y_center - width / 2 : y_center; 
    // Make the stopper
    translate([x, y, base_h]) {
        mirror([x_mirror, y_mirror, 0])
            cube([width, divider_w, divider_h]);
    }
}
module connector(x_center, y_center, adjust_center, adjust_walls, x_mirror, y_mirror, width, height) {
    // Correct x and y coordinates for the outerwalls
    x_corrected = ( adjust_center == "y" ) ? x_center - adjust_walls : x_center;
    y_corrected = ( adjust_center == "x" ) ? y_center - adjust_walls : y_center;
    // Correct x and y coordinates for centering
    x = ( adjust_center == "x" ) ? x_center - width / 2 : x_corrected;
    y = ( adjust_center == "y" ) ? y_center - width / 2 : y_corrected;  
    // Make the connector
    translate([x, y, 0]) {
        mirror([x_mirror, y_mirror, 0])
            linear_extrude(height = base_h)
                polygon(points=[[0,0],[width,0],[width-height,height],[height,height]]);
    }
}