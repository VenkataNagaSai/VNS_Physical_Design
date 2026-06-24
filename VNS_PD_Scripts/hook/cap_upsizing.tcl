proc upsize_cell {n} {
    set dn [get_object_name [get_flat_cells -of_objects \
        [get_pins [all_connected $n -leaf] -filter "direction == out"]]]
    set drn [get_attribute [get_flat_cells $dn] ref_name]
    puts "driver_name : $dn  driver_ref_name : $drn"
    regexp -nocase {(.+X)([0-9]+)(.+)} $drn temp rn ds vt
    if {$ds == 0} {
        set ds 1
    } else {
        set ds [expr $ds * 2]
    }
    size_cell $dn $rn$ds$vt
    set drn [get_attribute [get_cell $dn] ref_name]
    puts "driver_name : $dn  new_ref_name : $drn"
}
# Apply upsizing using dumped file
set fp [open $rpt_dir/cap.txt r]
while {[gets $fp line] >= 0} {
    if {[llength $line] == 5} {
        set net_name [lindex $line 0]
        catch {upsize_cell $net_name}
    }
}
close $fp

