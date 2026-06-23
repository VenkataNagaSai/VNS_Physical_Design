redirect ./reports/CTS/rt_skew.rpt {
  report_timing -path_type full_clock_expanded \
  -max_paths 10 -input_pins -capacitance \
  -delay_type max -nets -nosplit \
  -significant_digits 3 -slack less_than 0 \
  -transition_time
}

report_timing -from [get_cells I_PCI_TOP/R_0] \
              -path_type end -max_paths 10 -nosplit


report_timing -to [get_cells I_PCI_TOP/R_0] \
              -path_type end -max_paths 10 \
              -delay_type min -nosplit

insert_buffer [get_cells I_PCI_TOP/R_0/CLK] NBUFFX2_LVT

report_timing -from [get_cells I_PARSER/r_pcmd_out_reg[2]] \
              -to   [get_cells I_PCI_TOP/R_0] \
              -path_type full_clock

size_cell I_PCI_TOP/R_0/eco_cell DELLN1X2_LVT
