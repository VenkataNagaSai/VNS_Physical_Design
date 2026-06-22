# ------------------------------------------------------------------
# ICC2   : CTS Automated Script
# Tool   : Synopsys IC Compiler II (ICC2)
# Stage  : CTS
# Date   : 22-06-2026
# Author : Ravula Venkata Naga Sai
# ------------------------------------------------------------------

######################################################################
# CTS SPEC FILE
######################################################################
puts "INFO: Sourcing CTS specification..."

# -------------------------------------------------------------------
# Pre-CTS sanity checks
# -------------------------------------------------------------------
check_clock_trees
check_design -checks pre_clock_tree_stage

# -------------------------------------------------------------------
# Derive existing clock cell references
# -------------------------------------------------------------------
derive_clock_cell_references -output ./scripts/ref_cell.tcl

# -------------------------------------------------------------------
# Clock cell control
# -------------------------------------------------------------------
# Exclude all cells from CTS
set_lib_cell_purpose -exclude cts [get_lib_cells]

# Source derived reference cells
source ./scripts/ref_cell.tcl

# Allow only selected CTS cells (LVT/RVT buffers & inverters)
set_lib_cell_purpose -include cts \
    [get_lib_cells -filter \
        "ref_name =~ *BUF*LVT* || ref_name =~ *BUF*RVT* || \
         ref_name =~ *INV*LVT* || ref_name =~ *INV*RVT*"]


# -------------------------------------------------------------------
# Clock routing rules (NDR – double width & spacing)
# -------------------------------------------------------------------
remove_routing_rules -all
create_routing_rule icc_clock_double_spacing \
    -default_reference_rule \
    -multiplier_spacing 2 \
    -taper_distance 0.4 \
    -driver_taper_distance 0.4
set_clock_routing_rules \
    -net_type sink \
    -rules icc_clock_double_spacing \
    -min_routing_layer M4 \
    -max_routing_layer M5

# -------------------------------------------------------------------
# CTS constraints
# -------------------------------------------------------------------
current_mode func
set_max_transition 0.15 \
    -clock_path [get_clocks] \
    -corners [all_corners]

# -------------------------------------------------------------------
# Target skew (corner-based)
# -------------------------------------------------------------------
set_clock_tree_options -clock_tree [get_clocks] \
    -target_skew 0.05 \
    -corners [get_corners ss_125c]
set_clock_tree_options -clock_tree [get_clocks] \
    -target_skew 0.02 \
    -corners [get_corners ff_m40c]


# -------------------------------------------------------------------
# Clock uncertainty (scenario-aware)
# -------------------------------------------------------------------
foreach_in_collection scen [all_scenarios] {
    current_scenario $scen
    set_clock_uncertainty 0.10 -setup [all_clocks]
    set_clock_uncertainty 0.05 -hold  [all_clocks]
}

# -------------------------------------------------------------------
# Enable CRPR
# -------------------------------------------------------------------
set_app_options \
    -name time.remove_clock_reconvergence_pessimism \
    -value true

# -------------------------------------------------------------------
# CTS balance points (example – design Exceptions)
# -------------------------------------------------------------------
foreach_in_collection mode [all_modes] {
    current_mode $mode
    set_clock_balance_points \
        -consider_for_balancing true \
        -balance_points [get_pins "I_SDRAM_TOP/I_SDRAM_IF/sd_mux_*/SO"]
}

# -------------------------------------------------------------------
# Hold fixing cell control
# -------------------------------------------------------------------
set_lib_cell_purpose -exclude hold [get_lib_cells]
set_lib_cell_purpose -include hold \
    [get_lib_cells -filter \
        "ref_name =~ *DEL*HVT* || ref_name =~ *BUF*HVT*"]

puts "INFO: CTS specification completed."

# -------------------------------------------------------------------
# Define CTS report directory and Create, if it doesnot exist
# -------------------------------------------------------------------
set rpt_dir ./reports/CTS
if {![file exists $rpt_dir]} {
  file mkdir $rpt_dir}

######################################################################
# CTS RUN SCRIPT
# This script is executed AFTER sourcing cts_spec.tcl
######################################################################
puts "================ CTS FLOW STARTED ================"
#--------------------------------------------------
# Set prefixes for CTS and data path cells
#--------------------------------------------------
puts "INFO: Setting instance name prefixes..."

# Prefix for CTS-added cells
set_app_options -name opt.common.user_instance_name_prefix  -value clock_opt_clock_

# Prefix for data-path optimization cells
set_app_options -name opt.common.user_instance_name_prefix \
-value clock_opt_data_

#--------------------------------------------------
# 3. Remove existing global routes
#--------------------------------------------------
puts "INFO: Removing existing global routes..."
remove_routes -global_route

#--------------------------------------------------
# 4. Build Clock Tree (CTS build phase)
#--------------------------------------------------
puts "INFO: Building clock tree..."
clock_opt -to build_clock
save_block -as build_clock_done

#--------------------------------------------------
# 5. Route Clock Tree
#--------------------------------------------------
puts "INFO: Routing clock tree..."
clock_opt -from build_clock -to route_clock
save_block -as route_clock_done

#--------------------------------------------------
# 6. Post-CTS timing check
#--------------------------------------------------
puts "INFO: Reporting post-CTS timing..."
report_global_timing > $rpt_dir/cts_global_timing.rpt

#--------------------------------------------------
# 7. Enable aggressive hold fixing options
#--------------------------------------------------
puts "INFO: Enabling hold-fix optimization options..."
set_app_options -name clock_opt.hold.effort -value high
set_app_options -name ccd.hold_control_effort -value high
set_app_options -name opt.dft.clock_aware_scan_reorder -value true

#--------------------------------------------------
# 8. Final CTS optimization (skew + hold cleanup)
#--------------------------------------------------
puts "INFO: Running final CTS optimization..."
clock_opt
save_block -as final_clock_opt_done
puts "================ CTS FLOW COMPLETED ================"

######################################################################
# CTS QOR REPORT DUMP
######################################################################
set rpt_dir ./reports/CTS/CTS_qor

# Create directory if it does not exist
if {![file exists $rpt_dir]} {
    file mkdir $rpt_dir
}
puts "INFO: Dumping CTS QOR reports into $rpt_dir"

#--------------------------------------------------
# Global Timing
#--------------------------------------------------
report_global_timing > $rpt_dir/global_timing.rpt

#--------------------------------------------------
# Clock Latency Reports
#--------------------------------------------------
report_clock_qor -type latency \
    -scenarios func_ff_125c \
    -nosplit > $rpt_dir/clock_latency_func_ff_125c.rpt
report_clock_qor -type latency \
    -scenarios func_ss_m40c \
    -nosplit > $rpt_dir/clock_latency_func_ss_m40c.rpt

#--------------------------------------------------
# Clock DRC Violations
#--------------------------------------------------
report_clock_qor -type drc_violators \
    > $rpt_dir/clock_drc_violators.rpt

#--------------------------------------------------
# Minimum Pulse Width Violations
#--------------------------------------------------
report_min_pulse_width -all_violators \
    > $rpt_dir/min_pulse_width_violations.rpt

#---------------------------------------------------
# Max Transition Violations
#--------------------------------------------------
report_constraints -all_violators -max_transition \
    > $rpt_dir/max_transition_violations.rpt

#--------------------------------------------------
# Max Capacitance Violations
#--------------------------------------------------
report_constraints -all_violators -max_capacitance \
    > $rpt_dir/max_capacitance_violations.rpt
puts "INFO: CTS QOR report dumping completed"

# ------------------------------------------------------------------
# Save CTS Block
# ------------------------------------------------------------------
save_block -as cts
