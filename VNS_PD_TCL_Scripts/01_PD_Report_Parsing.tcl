# PD Report Parsing

# ---------------------------------------------
# Extract WNS
# ---------------------------------------------

regexp {WNS:\s*(-?\d+\.\d+)} $line match wns

# ---------------------------------------------
# Extract TNS
# ---------------------------------------------

regexp {TNS:\s*(-?\d+\.\d+)} $line match tns

# ---------------------------------------------
# Extract Startpoint
# ---------------------------------------------

regexp {Startpoint:\s+(\S+)} $line match start

# ---------------------------------------------
# Extract Endpoint
# ---------------------------------------------

regexp {Endpoint:\s+(\S+)} $line match end

# ---------------------------------------------
# Find Worst 10 Slacks
# ---------------------------------------------

lappend slacks $slack
set sorted [lsort -real $slacks]
puts [lrange $sorted 0 9]

# ---------------------------------------------
# Extract Slack from Timing Report
# ---------------------------------------------

if {[regexp {slack.*(-?\d+\.\d+)} $line match slack]} {
    puts $slack
}

# ---------------------------------------------
# Find Worst Slack (WNS)
# ---------------------------------------------

set wns 999
while {[gets $fp line] >= 0} {
    if {[regexp {slack.*(-?\d+\.\d+)} $line match slack]} {
        if {$slack < $wns} {
            set wns $slack
        }
    }
}
puts $wns

# ---------------------------------------------
# Count Violations
# ---------------------------------------------

set count 0
while {[gets $fp line] >= 0} {
    if {[regexp {VIOLATED} $line]} {
        incr count
    }
}
puts $count

