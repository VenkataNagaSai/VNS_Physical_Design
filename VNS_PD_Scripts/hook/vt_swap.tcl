proc vt_swap nn {
    set dn [get_object_name [get_flat_cells -of_objects \
        [get_pins [all_connected $nn -leaf] -filter "direction == out"]]]
    set drn [get_attribute [get_flat_cells $dn] ref_name]
    puts "driver_name : $dn driver_ref_name : $drn"
    regexp -nocase {(.+X)([0-9]+)(.+)} $drn temp rn ds vt
    if {$vt == "_RVT" || $vt == "_LVT"} {
        set vt "_HVT"
    }
    size_cell $dn $rn$ds$vt
    set drn [get_attribute [get_cell $dn] ref_name]
    puts "driver_name : $dn new_ref_name : $drn"
}
# Apply VT swap using dumped file
set fp [open $rpt_dir/tran.txt r]
while {[gets $fp line] >= 0} {
    if {[llength $line] == 5} {
        set net_name [lindex $line 0]
        catch {vt_swap $net_name}
    }
}
close $fp
