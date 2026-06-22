# ----------------------------------------------
# PD ICC2 TCL Scripts
# ----------------------------------------------

# ----------------------------------------------
# Count Number of Cells
# ----------------------------------------------

set count [sizeof_collection [get_cells *]]
puts "Total cells = $count"

# ----------------------------------------------
# List All Sequential Cells
# ----------------------------------------------

foreach_in_collection cell [get_cells -filter "is_sequential==true"] {
    puts [get_object_name $cell]
}

# ----------------------------------------------
# Find All Buffers
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    set ref [get_attribute $cell ref_name]
    if {[string match *BUF* $ref]} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# Print All Clock Pins
# ----------------------------------------------

foreach_in_collection pin [get_pins *] {
    if {[string match *CLK* [get_object_name $pin]]} {
        puts [get_object_name $pin]
    }
}

# ----------------------------------------------
# Find Cells in a Specific Area
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    set x [get_attribute $cell x_coordinate]
    if {$x > 100 && $x < 200} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# Calculate Utilization
# ----------------------------------------------

set core_area 1000000
set stdcell_area 700000
set util [expr {$stdcell_area*100.0/$core_area}]
puts "Utilization = $util %"

# ----------------------------------------------
# Find Unconnected Ports
# ----------------------------------------------

foreach_in_collection port [get_ports *] {
    if {[sizeof_collection [all_connected $port]] == 0} {
        puts [get_object_name $port]
    }
}

# ----------------------------------------------
# Generate Cell Count by Reference
# ----------------------------------------------

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

# ----------------------------------------------
# Count Buffers
# ----------------------------------------------

set count 0
foreach_in_collection cell [get_cells *] {
    set ref [get_attribute $cell ref_name]
    if {[string match *BUF* $ref]} {
        incr count
    }
}
puts $count

# ----------------------------------------------
# List All Clocks
# ----------------------------------------------

foreach_in_collection clk [get_clocks *] {
    puts [get_object_name $clk]
}

# ----------------------------------------------
# List All Macros
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    if {[get_attribute $cell is_hard_macro]} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# Find Cells with Area greater than 10um^2
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    set area [get_attribute $cell area]
    if {$area > 10} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# Find Unplaced Cells
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    if {![get_attribute $cell is_placed]} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# List Dont-Touch Cells
# ----------------------------------------------

foreach_in_collection cell [get_cells *] {
    if {[get_attribute $cell dont_touch]} {
        puts [get_object_name $cell]
    }
}

# ----------------------------------------------
# Find High-Fanout Nets or Fanout greater than 100
# ----------------------------------------------

foreach_in_collection net [get_nets *] {
    set fanout [sizeof_collection [all_fanout -flat -from $net]]
    if {$fanout > 100} {
        puts [get_object_name $net]
    }
}

# ----------------------------------------------
# Find Nets with Capacitance greater than particular Threshold
# ----------------------------------------------

foreach_in_collection net [get_nets *] {
    set cap [get_attribute $net capacitance]
    if {$cap > 0.5} {
        puts [get_object_name $net]
    }
}

# ----------------------------------------------
# Find Floating Nets
# ----------------------------------------------

foreach_in_collection net [get_nets *] {
    if {[sizeof_collection [all_connected $net]] < 2} {
        puts [get_object_name $net]
    }
}

