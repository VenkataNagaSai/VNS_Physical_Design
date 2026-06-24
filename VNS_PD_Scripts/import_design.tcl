# ---------------------------------------------
# ICC2   : Import Design Automated Script 
# Tool   : Synopsys IC Compiler II (ICC2)
# Stage  : Import Design
# Date   : 22-06-2026
# Author : Ravula Venkata Naga Sai
# ---------------------------------------------

# ---------------------------------------------
# Search Path
# ---------------------------------------------
set search_path "$search_path /home/vns/PHYSICAL_DESIGN/ICC2/ORCA_TOP/ref/CLIBs/CLIBs"

# ---------------------------------------------
# Reference Libraries
# ---------------------------------------------
set ref_ndm_list {saed32_1p9m_tech.ndm saed32_hvt.ndm saed32_lvt.ndm saed32_rvt.ndm saed32_sram_lp.ndm}

# ---------------------------------------------
# Create Working Library
# ---------------------------------------------
if {[file exists ORCA_TOP.nlib]} {
 sh mv ORCA_TOP.nlib ORCA_TOP_bkup.nlib}
create_lib -ref_libs $ref_ndm_list -use_technology_lib saed32_1p9m_tech.ndm ORCA_TOP.nlib
save_lib

# ---------------------------------------------
# Read Design Gate Level Netlist (GLN)
# ---------------------------------------------
read_verilog ./inputs/ORCA_TOP.v
if {[link_block]} {
    puts "Successfully linked"
} else {
    puts "Linking failed"
}

# ---------------------------------------------
# Load Timing Constraints
# ---------------------------------------------
source -e -v ./inputs/sdc_constraints/MMMC.tcl

# ---------------------------------------------
# Load ScanDEF
# ---------------------------------------------
read_def ./inputs/ORCA_TOP.scandef

# ---------------------------------------------
# Load UPF (Power Intent)
# ---------------------------------------------
load_upf ./inputs/ORCA_TOP.upf
commit_upf

# ----------------------------------------------
# Report directory (create if it doesnot exist)
# ----------------------------------------------
set rpt_dir ./reports/IMPORT_DESIGN
if {![file exists $rpt_dir]} {
  file mkdir $rpt_dir}

# ---------------------------------------------
# Import Design Checks and Reports
# ---------------------------------------------
set stage import_design
check_netlist > $rpt_dir/check_netlist_$stage.rpt
report_global_timing > $rpt_dir/fp_global_timing_$stage.rpt
check_mv_design > $rpt_dir/mv_design_$stage.rpt
report_design_mismatch > $rpt_dir/design_mismatch_$stage.rpt
report_ref_libs > $rpt_dir/ref_lib_$stage.rpt
report_qor > $rpt_dir/qor_$stage.rpt
check_scan_chain > $rpt_dir/scan_chain_info_$stage.rpt

# ---------------------------------------------
# Save Import Design Block
# ---------------------------------------------
save_block -as import_design
