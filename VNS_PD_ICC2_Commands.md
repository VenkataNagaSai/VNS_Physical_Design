# PD ICC2 Commands

These PD ICC2 commands are most commonly used during implementation, debugging, timing closure. 

## Table of Contents

- [1. Design Initialization](#1-design-initialization)
- [2. Library Commands](#2-library-commands)
- [3. Object Query Commands](#3-object-query-commands)
- [4. Attribute Commands](#4-attribute-commands)
- [5. Floorplan](#5-floorplan)
- [6. Powerplan](#6-powerplan)
- [7. Placement](#7-placement)
- [8. High Fanout Optimization](#8-high-fanout-optimization)
- [9. CTS](#9-cts)
- [10. Route](#10-route)
- [11. Timing Commands](#11-timing-commands)
- [12. QoR Reports](#12-qor-reports)
- [13. Congestion Reports](#13-congestion-reports)
- [14. DRC Commands](#14-drc-commands)
- [15. ECO Commands](#15-eco-commands)
- [16. Useful Reports](#16-useful-reports)
- [17. Collections](#17-collections)
- [18. Filter Commands](#18-filter-commands)
- [19. Database Navigation Commands](#19-database-navigation-commands)
- [20. GUI Commands](#20-gui-commands)
- [21. Common Debug Commands](#21-common-debug-commands)
- [22. Routing Rule Commands](#22-routing-rule-commands)
- [23. NDR Commands](#23-ndr-commands)
- [24. Common Query Commands](#24-common-query-commands)
- [25. Frequently Used Attribute Queries](#25-frequently-used-attribute-queries)
- [26. Most Frequently Used ICC2 Commands](#26-most-frequently-used-icc2-commands)


## 1. Design Initialization

```tcl
read_verilog design.v
read_db design.db
read_sdc constraints.sdc
link_block
current_block
save_block
open_block
copy_block
```

### Purpose

* Load design
* Read constraints
* Open design database
* Save design database

## 2. Library Commands

```tcl
get_libs
get_lib_cells
get_lib_pins
report_lib
```

### Useful Library Commands

```tcl
get_lib_cells *BUF*
get_lib_cells *INV*
```

## 3. Object Query Commands

### Cells

```tcl
get_cells
get_flat_cells
get_cells -hierarchical
```

#### Example

```tcl
get_cells *U123*
```

### Pins

```tcl
get_pins
```

#### Example

```tcl
get_pins U123/A
```

### Nets

```tcl
get_nets
```

### Ports

```tcl
get_ports
```

### Clocks

```tcl
get_clocks
```

## 4. Attribute Commands

Very frequently used.

```tcl
get_attribute
set_attribute
```

### Attribute Command Examples

```tcl
get_attribute [get_cells U1] bbox
get_attribute [get_cells U1] physical_status
get_attribute [get_nets clk] net_type
```

## 5. Floorplan

```tcl
initialize_floorplan
create_bounds
create_placement_blockage
create_route_blockage
create_keepout_margin
shape_blocks
report_floorplan
```

### Floorplan Checks

```tcl
check_floorplan
report_utilization
```

## 6. Powerplan

```tcl
create_pg_ring
create_pg_mesh
create_pg_std_cell_conn_pattern
compile_pg
```

### Powerplan Checks

```tcl
check_pg_connectivity
report_pg
```

## 7. Placement

### Placement Main Commands

```tcl
place_opt
legalize_placement
```

### Individual Placement stage Commands

```tcl
place_opt -from initial_place
place_opt -from initial_drc
place_opt -from initial_opto
place_opt -from final_place
place_opt -from final_opto
```

### Placement Checks

```tcl
check_legality
report_congestion
report_utilization
```

## 8. High Fanout Optimization

```tcl
report_net_fanout
all_high_fanout
```

## 9. CTS

```tcl
clock_opt
```

### CTS Checks

```tcl
check_clock_trees
report_clock_tree
report_clock_timing
report_clock_qor
```

### Clock Latency Check

```tcl
report_clock_timing -type latency
```

### Clock Skew Check

```tcl
report_clock_timing -type skew
```

These are the most commonly used CTS debugging commands. 

## 10. Route

### Global Route

```tcl
route_global
```

### Track Assignment

```tcl
route_track
```

### Detail Route

```tcl
route_detail
```

### Route Optimization

```tcl
route_opt
```

### Route Checks

```tcl
report_route_status
report_routing_rules
```

## 11. Timing Commands

Most important command

```tcl
report_timing
```

### Timing Command Examples

```tcl
report_timing -max_paths 10
report_timing -delay max
report_timing -delay min
report_timing -nets
report_timing -transition_time
```

Timing reports help identify setup/hold violations and optimization opportunities. 

## 12. QoR Reports

```tcl
report_qor
report_constraint
report_global_timing
report_clock_timing
report_power
report_area
```

## 13. Congestion Reports

```tcl
report_congestion
report_congestion -grid
```

## 14. DRC Commands

```tcl
check_routes
check_legality
check_design
check_physical_constraints
```

## 15. ECO Commands

```tcl
eco_opt
add_buffer
insert_buffer
remove_buffer
size_cell
change_link
```

## 16. Useful Reports

```tcl
report_area
report_cell
report_clock_timing
report_clock_tree
report_congestion
report_constraint
report_design
report_net
report_pin
report_port
report_power
report_qor
report_timing
report_utilization
```

## 17. Collections

### To count objects

```tcl
sizeof_collection
```

### Example

```tcl
sizeof_collection [get_cells]
```

## 18. Filter Commands

```tcl
get_cells -filter "is_sequential==true"
get_cells -filter "is_hard_macro==true"
get_cells -filter "physical_status==fixed"
```

## 19. Database Navigation Commands

```tcl
all_inputs
all_outputs
all_registers
all_clocks
current_design
current_block
```

## 20. GUI Commands

```tcl
start_gui
gui_zoom
gui_fit
change_selection
highlight_objects
```

## 21. Common Debug Commands

### Locate a cell

```tcl
change_selection [get_cells U123]
```

### Highlight net

```tcl
change_selection [get_nets clk]
```

### Locate pin

```tcl
change_selection [get_pins U123/A]
```

## 22. Routing Rule Commands

```tcl
create_routing_rule
set_clock_routing_rules
report_routing_rules
```

## 23. NDR Commands

```tcl
create_routing_rule
set_clock_routing_rules
remove_routing_rules
report_routing_rules
```

## 24. Common Query Commands

```tcl
get_cells
get_clocks
get_layers
get_lib_cells
get_lib_pins
get_nets
get_pins
get_ports
get_vias
```

## 25. Frequently Used Attribute Queries

```tcl
area
bbox
height
is_clock
is_hard_macro
is_sequential
is_soft_macro
physical_status
pin_count
width
```

## 26. Most Frequently Used ICC2 Commands
 
* `change_selection`
* `check_clock_trees`
* `check_legality`
* `check_pg_connectivity`
* `check_routes`
* `clock_opt`
* `compile_pg`
* `create_keepout_margin`
* `create_pg_mesh`
* `create_pg_ring`
* `create_placement_blockage`
* `create_route_blockage`
* `create_routing_rule`
* `eco_opt`
* `get_attribute`
* `get_cells`
* `get_clocks`
* `get_nets`
* `get_pins`
* `get_ports`
* `highlight_objects`
* `initialize_floorplan`
* `insert_buffer`
* `legalize_placement`
* `place_opt`
* `report_area`
* `report_cell`
* `report_clock_timing`
* `report_clock_tree`
* `report_congestion`
* `report_constraint`
* `report_design`
* `report_floorplan`
* `report_global_timing`
* `report_net_fanout`
* `report_net`
* `report_pin`
* `report_port`
* `report_power`
* `report_qor`
* `report_route_status`
* `report_routing_rules`
* `report_timing`
* `report_utilization`
* `route_opt`
* `set_attribute`
* `set_clock_routing_rules`
* `size_cell`
* `sizeof_collection`
* `start_gui`
