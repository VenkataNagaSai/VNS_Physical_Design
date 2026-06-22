# ----------------------------------------------
# STA Report Analysis
# ----------------------------------------------

# ----------------------------------------------
# Print all Setup Violating Timing Paths
# ----------------------------------------------
set count 0
foreach_in_collection path [get_timing_paths -slack_lesser_than 0] {
    puts "The $path has Setup slack: [get_attribute $path slack]"
    incr count
}
puts "No of Setup Violations = $count"

# ----------------------------------------------
# Find Worst Slack
# ----------------------------------------------

set wns 999
foreach_in_collection path [get_timing_paths -max_paths 1000] {
    set slack [get_attribute $path slack]
    if {$slack < $wns} {
        set wns $slack
    }
}
puts "WNS = $wns"

# ----------------------------------------------
# Parse Timing Report
# ----------------------------------------------

set fp [open timing.rpt r]
while {[gets $fp line] >= 0} {
    if {[regexp {slack.*(-?\d+\.\d+)} $line match slack]} {
        puts "Slack = $slack"
    }
}
close $fp

# ----------------------------------------------
# Generate ECO Buffer List
# ----------------------------------------------

set fp [open eco_buf.tcl w]
foreach_in_collection net [get_nets *] {
    set fanout [sizeof_collection [all_fanout -flat -from $net]]
    if {$fanout > 50} {
        puts $fp "insert_buffer [get_object_name $net]"
    }
}
close $fp

# ----------------------------------------------
# Generate ECO Commands
# ----------------------------------------------

set fp [open eco.tcl w]
puts $fp "size_cell U123 BUF_X4"
close $fp

