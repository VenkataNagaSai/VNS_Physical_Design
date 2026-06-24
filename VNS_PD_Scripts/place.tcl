# ---------------------------------------------
# ICC2   : Placement Automated Script
# Tool   : Synopsys IC Compiler II (ICC2)
# Stage  : Placement
# Date   : 22-06-2026
# Author : Ravula Venkata Naga Sai
# ---------------------------------------------

# ---------------------------------------------
# Utility: Safe mkdir
# ---------------------------------------------

proc safe_mkdir {dir} {
    if {![file exists $dir]} {
        file mkdir $dir
    }
}
safe_mkdir ./reports
safe_mkdir ./reports/PLACEMENT
safe_mkdir ./reports/PRE_PLACEMENT

# ---------------------------------------------
# PRE-PLACEMENT CHECKS
# ---------------------------------------------

proc pre_placement_checks {} {
    set rpt_dir ./reports/PRE_PLACEMENT
    redirect $rpt_dir/pg_checks.rpt {
        check_pg_connectivity -check_std_cell_pins none
        check_pg_drc -ignore_std_cells
        check_pg_missing_vias
    }
    redirect $rpt_dir/mv_checks.rpt {
        check_mv_design
    }
    redirect $rpt_dir/physical_checks.rpt {
        check_physical_constraints
check_boundary_cells
        check_legality -verbose
    }
    redirect $rpt_dir/qor_summary.rpt {
        report_qor -summary
    }
    redirect $rpt_dir/utilization.rpt {
        report_utilization -config pl_util
    }
}
puts "INFO: Running pre-placement checks"
pre_placement_checks
check_design -check pre_placement_stage

# ---------------------------------------------
# READ SCAN + MMMC
# ---------------------------------------------
remove_scan_def
read_def ./inputs/ORCA_TOP.scandef
source   ./inputs/sdc_constraints/MMMC.tcl

# ---------------------------------------------
# PLACEMENET APP OPTIONS & ATTRIBUTES
# ---------------------------------------------
set_attribute [get_lib_cells -nocase *tie*] dont_use  false
set_attribute [get_lib_cells -nocase *tie*] dont_touch false

set_app_options -name place.legalize.enable_advanced_legalizer -value true
set_app_options -name place.legalize.legalizer_search_and_repair -value true
set_app_options -name place.coarse.auto_density_control -value true
set_app_options -name place.coarse.auto_timing_control  -value true
set_app_options -name place.coarse.legalizer_driven_placement -value true
set_app_options -list {plan.place.congestion_driven_mode both}


# Clock ideal for placement
set_ideal_network [get_clocks *]

# Routing limits
set_ignored_layers -min_routing_layer M2 -max_routing_layer M6
set_app_options -name route.common.net_max_layer_mode -value hard
set_app_options -name route.common.net_min_layer_mode -value allow_pin_connection

# ---------------------------------------------
# FIX MACROS
# ---------------------------------------------
set macros [get_flat_cells -filter {is_hard_macro && physical_status != fixed}]
if {[sizeof_collection $macros] > 0} {
    set_fixed_objects $macros
}

# ---------------------------------------------
# COARSE PLACEMENT
# ---------------------------------------------
create_placement
legalize_placement
refine_placement
save_block -as rough_legalized_placement

# ---------------------------------------------
# REPORT PROCEDURE
# ---------------------------------------------
proc dump_place_reports {stage rpt_file} {
    redirect $rpt_file {
        puts "============= $stage REPORT ============="
        report_constraints
        report_constraints -max_capacitance -all_violators -scenarios *
        report_constraints -max_transition  -all_violators -scenarios *
        report_congestion -rerun_global_router
        report_utilization -config pl_util
        report_global_timing
        report_net_fanout -high_fanout
    }
}

# ---------------------------------------------
# PLACEMENT STAGE - CELL SUMMARY PROCEDURE
# ---------------------------------------------
proc cell_summary {prefix {rpt_file ""}} {
    # -------------------------------
    # All Inserted cells
    # -------------------------------
    set cells [get_flat_cells -filter "name =~ ${prefix}*"]
    set total_cells [sizeof_collection $cells]

    set total_area 0
    foreach_in_collection c $cells {
        set total_area [expr {$total_area + [get_attr $c area]}]
    }
    # -------------------------------
    # Buffers
    # -------------------------------
    set buf_cells [get_flat_cells -filter "name =~ ${prefix}* && ref_name =~ *BUF*"]
    set total_buf [sizeof_collection $buf_cells]

    set buf_area 0
    foreach_in_collection b $buf_cells {
        set buf_area [expr {$buf_area + [get_attr $b area]}]
    }
    # -------------------------------
    # Inverters
    # -------------------------------
    set inv_cells [get_flat_cells -filter "name =~ ${prefix}* && ref_name =~ *INV*"]
    set total_inv [sizeof_collection $inv_cells]

    set inv_area 0
    foreach_in_collection i $inv_cells {
        set inv_area [expr {$inv_area + [get_attr $i area]}]
    }
    # -------------------------------
    # Display on terminal
    # -------------------------------
    puts "--------------------------------------------"
    puts "CELL SUMMARY : $prefix"
    puts "--------------------------------------------"
    puts "Total cells added     : $total_cells"
    puts "Total cell area       : $total_area"
    puts "Buffers added         : $total_buf"
    puts "Total buffer area     : $buf_area"
    puts "Inverters added       : $total_inv"
    puts "Total inverter area   : $inv_area"
    puts "--------------------------------------------"

# ----------------------------------------------
# Report directory (create if it doesnot exist)
# ----------------------------------------------
set rpt_dir ./reports/PLACEMENT
if {![file exists $rpt_dir]} {
  file mkdir $rpt_dir}

# ---------------------------------------------
# Placement Stagewise Checks and Reports
# ---------------------------------------------

# ---------------------------------------------
# INITIAL DRC
# ---------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value initial_drc
place_opt -from initial_drc -to initial_drc
dump_place_reports INITIAL_DRC $rpt_dir/initial_drc.rpt
cell_summary initial_drc
save_block -as initial_drc_placement

# ---------------------------------------------
# INITIAL OPTO
# ---------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value initial_opto
place_opt -from initial_opto -to initial_opto
dump_place_reports INITIAL_OPTO $rpt_dir/initial_opto.rpt
cell_summary initial_opto
save_block -as initial_opto_placement

# ---------------------------------------------
# FINAL PLACE
# ---------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value final_place
place_opt -from final_place-to final_place
dump_place_reports FINAL_PLACE $rpt_dir/final_place.rpt
cell_summary final_place
save_block -as final_place_done

# ---------------------------------------------
# FINAL OPTO
# ---------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value final_opto
place_opt -from final_opto -to final_opto
dump_place_reports FINAL_OPTO $rpt_dir/final_opto.rpt
cell_summary final_opto
save_block -as final_opto_done
puts "INFO: Placement flow completed successfully"

# ---------------------------------------------
# Save Placement Block
# ---------------------------------------------
save_block -as placement
