proc insert_buffer nn {
    set le [get_attribute [get_nets $nn] dr_length]
    if {$le <= 101} {
        set di [expr {$le/2}]
        add_buffer_on_route -repeater_distance $di \
            -lib_cell NBUFFX2_HVT [get_nets $nn] \
            -cell_prefix user_buffer
    } elseif {$le < 300 && $le > 100} {
        set di [expr {$le/2}]
        add_buffer_on_route -repeater_distance $di \
            -lib_cell NBUFFX4_HVT [get_nets $nn] \
            -cell_prefix user_buffer
    } else {
        set di [expr {$le/2}]
        add_buffer_on_route -repeater_distance $di \
            -lib_cell NBUFFX8_HVT [get_nets $nn] \
            -cell_prefix user_buffer
    }
}

# Apply buffering using SAME cap report
set fp [open $rpt_dir/cap.txt r]
while {[gets $fp line] >= 0} {
    if {[llength $line] == 5} {
        set net_name [lindex $line 0]
        catch {insert_buffer $net_name}
    }
}
close $fp

# Final Legalization
legalize_placement -incremental
