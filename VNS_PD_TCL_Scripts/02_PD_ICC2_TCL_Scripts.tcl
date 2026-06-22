# PD ICC2 TCL Scripts

# Count Number of Cells

set count [sizeof_collection [get_cells *]]
puts "Total cells = $count"

# List All Sequential Cells

foreach_in_collection cell [get_cells -filter "is_sequential==true"] {
    puts [get_object_name $cell]
}

# Find All Buffers

foreach_in_collection cell [get_cells *] {
    set ref [get_attribute $cell ref_name]

    if {[string match *BUF* $ref]} {
        puts [get_object_name $cell]
    }
}

# Find Cells with High Fanout

foreach_in_collection net [get_nets *] {
    set fanout [sizeof_collection [all_fanout -flat -from $net]]

    if {$fanout > 100} {
        puts "[get_object_name $net] : $fanout"
    }
}

# Print All Violating Timing Paths

foreach_in_collection path [get_timing_paths -slack_lesser_than 0] {
    puts [get_attribute $path slack]
}

# Find Worst Slack

set wns 999

foreach_in_collection path [get_timing_paths -max_paths 1000] {

    set slack [get_attribute $path slack]

    if {$slack < $wns} {
        set wns $slack
    }
}

puts "WNS = $wns"
---

# Parse Timing Report

set fp [open timing.rpt r]

while {[gets $fp line] >= 0} {

    if {[regexp {slack.*(-?\d+\.\d+)} $line match slack]} {
        puts "Slack = $slack"
    }
}

close $fp

# Print All Clock Pins

foreach_in_collection pin [get_pins *] {

    if {[string match *CLK* [get_object_name $pin]]} {
        puts [get_object_name $pin]
    }
}

# Find Cells in a Specific Area

foreach_in_collection cell [get_cells *] {

    set x [get_attribute $cell x_coordinate]

    if {$x > 100 && $x < 200} {
        puts [get_object_name $cell]
    }
}

# Calculate Utilization

set core_area 1000000
set stdcell_area 700000

set util [expr {$stdcell_area*100.0/$core_area}]

puts "Utilization = $util %"

# Find Unconnected Ports

foreach_in_collection port [get_ports *] {

    if {[sizeof_collection [all_connected $port]] == 0} {
        puts [get_object_name $port]
    }
}

# Count Setup Violations

set count 0

foreach_in_collection path \
    [get_timing_paths -slack_lesser_than 0] {

    incr count
}

puts "Violations = $count"

# Generate ECO Buffer List

set fp [open eco_buf.tcl w]

foreach_in_collection net [get_nets *] {

    set fanout [sizeof_collection \
        [all_fanout -flat -from $net]]

    if {$fanout > 50} {
        puts $fp "insert_buffer [get_object_name $net]"
    }
}

close $fp

# Find Floating Nets

foreach_in_collection net [get_nets *] {

    if {[sizeof_collection [all_connected $net]] < 2} {
        puts [get_object_name $net]
    }
}

# Generate Cell Count by Reference

array set count {}

foreach_in_collection cell [get_cells *] {

    set ref [get_attribute $cell ref_name]

    if {[info exists count($ref)]} {
        incr count($ref)
    } else {
        set count($ref) 1
    }
}

foreach ref [array names count] {
    puts "$ref : $count($ref)"
}

# List Sequential Cells

foreach_in_collection cell [get_cells -filter "is_sequential==true"] {
    puts [get_object_name $cell]
}

# Find High-Fanout Nets

foreach_in_collection net [get_nets *] {
    set fanout [sizeof_collection [all_fanout -flat -from $net]]
    if {$fanout > 100} {
        puts [get_object_name $net]
    }
}

# Count Buffers

set count 0
foreach_in_collection cell [get_cells *] {
    set ref [get_attribute $cell ref_name]
    if {[string match *BUF* $ref]} {
        incr count
    }
}
puts $count

# Generate ECO Commands

set fp [open eco.tcl w]
puts $fp "size_cell U123 BUF_X4"
close $fp

# List All Clocks

foreach_in_collection clk [get_clocks *] {
    puts [get_object_name $clk]
}

# Count Registers

set reg_count [sizeof_collection [get_cells -filter "is_sequential==true"]]
puts $reg_count

# List All Macros

foreach_in_collection cell [get_cells *] {
    if {[get_attribute $cell is_hard_macro]} {
        puts [get_object_name $cell]
    }
}

# Find Cells with Area > 10

foreach_in_collection cell [get_cells *] {
    set area [get_attribute $cell area]
    if {$area > 10} {
        puts [get_object_name $cell]
    }
}

# Find Unplaced Cells

foreach_in_collection cell [get_cells *] {
    if {![get_attribute $cell is_placed]} {
        puts [get_object_name $cell]
    }
}

# List Dont-Touch Cells

foreach_in_collection cell [get_cells *] {
    if {[get_attribute $cell dont_touch]} {
        puts [get_object_name $cell]
    }
}

# Find Nets with Capacitance > Threshold

foreach_in_collection net [get_nets *] {
    set cap [get_attribute $net capacitance]
    if {$cap > 0.5} {
        puts [get_object_name $net]
    }
}

# Find Fanout > 50

foreach_in_collection net [get_nets *] {
    set fanout [sizeof_collection [all_fanout -flat -from $net]]
    if {$fanout > 50} {
        puts [get_object_name $net]
    }
}

