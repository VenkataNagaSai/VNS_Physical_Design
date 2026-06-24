# ---------------------------------------------
# ICC2   : ROUTING Automated Script
# Tool   : Synopsys IC Compiler II (ICC2)
# Stage  : ROUTING
# Date   : 22-06-2026
# Author : Ravula Venkata Naga Sai
# ---------------------------------------------

################################################
# ROUTING STAGE
################################################
puts "INFO: Routing stage started..."

# ---------------------------------------------
# Pre-routing checks
# ---------------------------------------------
set rpt_dir "./reports/PRE_ROUTE"

# ---------------------------------------------
# Create report directory automatically
# ---------------------------------------------
if {![file exists $rpt_dir]} {
    file mkdir $rpt_dir
    puts "INFO: Created report directory $rpt_dir"
} else {
    puts "INFO: Using existing report directory $rpt_dir"
}

# ---------------------------------------------
# Routability check
# ---------------------------------------------
puts "INFO: Running check_routability..."
check_routability > $rpt_dir/routability.rpt

# ---------------------------------------------
# Pre-route design checks
# ---------------------------------------------
puts "INFO: Running pre-route design checks..."
check_design -check pre_route_stage > $rpt_dir/pre_route_design_check.rpt
puts "INFO: Pre-route checks completed successfully"

# ---------------------------------------------
# Enable timing-driven routing
# ---------------------------------------------
set_app_options -name route.global.timing_driven  -value true
set_app_options -name route.track.timing_driven   -value true
set_app_options -name route.detail.timing_driven  -value true

# ---------------------------------------------
# Enable crosstalk-aware routing
# ---------------------------------------------
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.track.crosstalk_driven  -value true

# ---------------------------------------------
# Timing analysis options
# ---------------------------------------------
set_app_options -name time.si_enable_analysis          -value true
set_app_options -name time.si_xtalk_composite_aggr_mode -value statistical
set_app_options -name time.all_clocks_propagated       -value true

# ---------------------------------------------
# Improve DRC convergence
# ---------------------------------------------
set_app_options -name route.detail.eco_max_number_of_iterations -value 20
set_app_options -name route.detail.drc_convergence_effort_level -value high
set_app_options -name route.detail.force_max_number_iterations  -value true

# ---------------------------------------------
# Prefix for routing-added cells
# ---------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value route_opt_

# ---------------------------------------------
# Read antenna rules
# ---------------------------------------------
Source /home/vns/PHYSICAL_DESIGN/ICC2/ORCA_TOP/ref/tech/saed32nm_ant_1p9m.tcl

# ---------------------------------------------
# Perform routing
#   1) Global routing
#   2) Track assignment
#   3) Detail routing
# ---------------------------------------------
route_auto \
    -save_after_global_route true \
    -save_after_track_assignment true \
    -save_after_detail_route true

# ---------------------------------------------
# Routing optimization
# ---------------------------------------------
route_opt
# ---------------------------------------------
# Save block
# ---------------------------------------------
save_block -as route_opt_done
puts "INFO: Routing stage completed successfully"

################################################
# POST ROUTING CHECKS 
################################################

set rpt_dir "./reports/POST_ROUTE"
# ---------------------------------------------
# Create directory automatically 
# ---------------------------------------------
if {![file exists $rpt_dir]} {
    file mkdir $rpt_dir
    puts "INFO: Created report directory $rpt_dir"
} else {
    puts "INFO: Report directory already exists: $rpt_dir"
}

# ---------------------------------------------
# Power / Ground checks
# ---------------------------------------------
puts "INFO: Running PG connectivity check..."
check_pg_connectivity  > $rpt_dir/pg_connectivity.rpt
puts "INFO: Running PG missing vias check..."
check_pg_missing_vias  > $rpt_dir/pg_missing_vias.rpt
puts "INFO: Running PG DRC check..."
check_pg_drc > $rpt_dir/pg_drc.rpt

# ---------------------------------------------
# Routing checks
# ---------------------------------------------
puts "INFO: Running routing check..."
check_routes > $rpt_dir/route_check.rpt

# ---------------------------------------------
# LVS check
# ---------------------------------------------
puts "INFO: Running LVS check..."
check_lvs -max_error 0 > $rpt_dir/lvs.rpt
puts "INFO: All post-routing checks completed successfully"
