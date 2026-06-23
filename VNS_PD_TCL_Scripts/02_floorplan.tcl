# ---------------------------------------------
# ICC2   : Floorplan Automated Script 
# Tool   : Synopsys IC Compiler II (ICC2)
# Stage  : Floorplan
# Date   : 22-06-2026
# Author : Ravula Venkata Naga Sai
# ---------------------------------------------

# ----------------------------------------------
# Creating Floorplan Block
# ----------------------------------------------
open_lib ORCA_TOP.nlib
copy_block -from_block import_design -to_block floorplan
open_block floorplan

# ----------------------------------------------
# Core & Die Area Creation
# ----------------------------------------------

# Defines utilization, offset, and chip shape before initializing floorplan.
# Core and die area setup
set utilization 0.75
set offset 5
set shape "L"
if {$shape == "L"} {
    set side_ratio {1 1 1 1}
}

# ----------------------------------------------
# Initialize Floorplan
# ----------------------------------------------

# Creates the core and die based on given parameters.
initialize_floorplan \
    -core_utilization $utilization \
    -core_offset $offset \
    -shape $shape \
    -use_site_row

# ----------------------------------------------
# Clean Old Constraints (Optional)
# ----------------------------------------------

# Removes any previous blockages and pin guides.
if {0} {
    remove_placement_blockages *
    remove_pin_guides *
}

# ----------------------------------------------
# Port Placement using Proc
# ----------------------------------------------

# Loads external script for port placement.
proc cord {coord} {
    set llx [lindex $coord 0 0]
    set lly [lindex $coord 0 1]
    set urx [lindex $coord 1 0]
    set ury [lindex $coord 1 1]
    set bbox [list [list $llx $lly] [list $urx $ury]]
    create_pin_guide -boundary $bbox -layers {M3 M5} -pin_spacing 5 [all_inputs]
    place_pin -ports [all_inputs]
    return
}
proc cord1 {coord} {
    set llx [lindex $coord 0 0]
    set lly [lindex $coord 0 1]
    set urx [lindex $coord 1 0]
    set ury [lindex $coord 1 1]
    set bbox1 [list [list $llx $lly] [list $urx $ury]]
    set all_output [get_ports [all_outputs]]
    set out_list [get_object_name $all_output]
    set group1 [lrange $out_list 0 61]
    create_pin_guide -boundary $bbox1 -layers {M5} -pin_spacing 1 $group1
    place_pin -ports $group1
    return
}
proc cord2 {coord} {
    set llx [lindex $coord 0 0]
    set lly [lindex $coord 0 1]
    set urx [lindex $coord 1 0]
    set ury [lindex $coord 1 1]
    set bbox2 [list [list $llx $lly] [list $urx $ury]]
    set all_output [get_ports [all_outputs]]
    set out_list [get_object_name $all_output]
    set group2 [lrange $out_list 61 end]
    create_pin_guide -boundary $bbox2 -layers {M5} -pin_spacing 1 $group2
    place_pin -ports $group2
    return
}

# Calling Port Placement Proc with Coordinates as Arguments
cord  {{0.0000 257.4720} {5.0000 429.4070}}
cord1 {{447.1680 529.5350} {452.1680 710.5840}}
cord2 {{889.3360 186.1770} {894.3360 326.0240}}

# ----------------------------------------------
# Remove Existing Voltage Areas (Optional)
# ----------------------------------------------

if {0} {
    remove_voltage_area *
}

# ----------------------------------------------
# Voltage Area Creation using Proc
# ----------------------------------------------

proc va_cord {cord} {
    set llx [expr [lindex $cord 0 0] + 5.016]
    set lly [expr [lindex $cord 0 1] + 5.016]
    set urx [expr [lindex $cord 1 0] + 5.016]
    set ury [expr [lindex $cord 1 1] + 5.016 + 1.672]
    set va  [list [list $llx $lly] [list $urx $ury]]
    puts "voltage_bbox_area = $va"
    create_voltage_area -power_domains PD_RISC_CORE -region $va -guard_band {{5.016 5.016}}
    return
}

# Calling Voltage Area Proc with Coordinates as Arguments
va_cord {{5.0000 5.0000} {402.3280 170.5280}}

# ----------------------------------------------
# Macro Placement
# ----------------------------------------------
set_app_options -name plan.macro.macro_place_only -value true
set_app_options -name plan.macro.grouping_by_hierarchy -value true
set_app_options -name plan.macro.spacing_rule_heights -value {15um 15um}
set_app_options -name plan.macro.spacing_rule_widths -value {15um 15um}

# If Macro placement is performed by tool based on the -floorplan option.
if {0} {
	create_placement -floorplan
	# legalize_macro_placement
	legalize_placement -incremental
}

# Sanity check: verify macros exist
if {[sizeof_collection [get_flat_cells -filter "is_hard_macro"]] == 0} {
    puts "WARNING: No hard macros found in the design!"
} else {
    puts "INFO: Hard macros detected: \
        [sizeof_collection [get_flat_cells -filter "is_hard_macro"]]"
}

# ----------------------------------------------
# Keepout Margin Creation
# ----------------------------------------------
if {$macro_cnt > 0} {
    create_keepout_margin -outer {1.5 1.5 1.5 1.5} $macro_cells
}

# ----------------------------------------------
# Derives blockages and exports them into a text file.
# ----------------------------------------------
set_app_option -name place.floorplane.sliver.size -value 4um 
derive_placement_blockages -f
redirect ./scripts/par_pl.txt {get_attr [get_placement_blockages] bbox}
remove_placement_blockages *

# ----------------------------------------------
# Partial Blockage creation from script
# ----------------------------------------------
set fh [open "/home/vns/vns_scripts/scripts/par_pl.txt" r]
set fb [read $fh]
foreach pl $fb {
    create_placement_blockage -type partial -boundary $pl
}

# Setting ignored layers
set_ignored_layers -min_routing_layer M2 -max_routing_layer M6

# Fix the Macros
set_fixed_objects [get_flat_cells -filter "is_hard_macro"]

# reset the placement (if required)
if {0} {
	reset_placement
}

# ----------------------------------------------
# Boundary cells
# ----------------------------------------------
get_lib_cells -nocase *dcap_hvt*
set b_cell [get_lib_cells -nocase *dcap_hvt*]
set_boundary_cell_rules \
    -left_boundary_cell  $b_cell \
    -right_boundary_cell $b_cell \
    -at_va_boundary
compile_boundary_cells
check_boundary_cells

# ----------------------------------------------
# Tap cells
# ----------------------------------------------
create_tap_cells -distance 30 -pattern stagger -lib_cell $b_cell -skip_fixed_cells
check_legality

# ----------------------------------------------
# Report directory (create if it doesnot exist)
# ----------------------------------------------
set rpt_dir "./reports/FLOORPLAN"
if {![file exists $rpt_dir]} {
    file mkdir $rpt_dir
}

# ----------------------------------------------
# Floorplan Checks and Reports
# ----------------------------------------------
set stage fp
check_boundary_cells       > $rpt_dir/boundary_cell_$stage.rpt
check_legality             > $rpt_dir/legality_$stage.rpt
check_physical_constraints > $rpt_dir/physical_constraints_$stage.rpt
check_pin_placement -wire_track true > $rpt_dir/pin_placement_$stage.rpt
report_congestion -rerun_global_router > $rpt_dir/congestion_$stage.rpt

# ----------------------------------------------
# Save Floorplan Block
# ----------------------------------------------
save_block -as floorplan
