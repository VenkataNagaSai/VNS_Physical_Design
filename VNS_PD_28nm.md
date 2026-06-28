# Physical Design Implementation (Netlist → GDSII) and Automation of a Single Core 32 Bit RISC Processor on 28nm Technology

<a id="top"></a>

## 📑 Table of Contents

- [Project Overview](#project-overview)
- [Project Objectives](#project-objectives)
- [Tools and Technology](#tools-and-technology)
- [Physical Design Flow (Stage-wise Automation)](#physical-design-flow-stage-wise-automation)
  - [Stage 1: Import Design](#stage-1-import-design)
    - [Import Design Objective](#import-design-objective)
    - [Import Design Automated Tasks](#import-design-automated-tasks)
    - [Import Design Generated Outputs](#import-design-generated-outputs)
  - [Stage 2: Floorplan](#stage-2-floorplan)
    - [Floorplan Objective](#floorplan-objective)
    - [Floorplan Automated Tasks](#floorplan-automated-tasks)
    - [Floorplan Generated Outputs](#floorplan-generated-outputs)
  - [Stage 3: Powerplan](#stage-3-powerplan)
    - [Powerplan Objective](#powerplan-objective)
    - [Powerplan Automated Tasks](#powerplan-automated-tasks)
    - [Powerplan Key Power Structures Implemented](#powerplan-key-power-structures-implemented)
    - [Powerplan Key Checks and Reports](#powerplan-key-checks-and-reports)
    - [Powerplan Generated Outputs](#powerplan-generated-outputs)
  - [Stage 4: Placement](#stage-4-placement)
    - [Placement Objective](#placement-objective)
    - [Placement Automated Tasks](#placement-automated-tasks)
    - [Placement Key Checks and Reports](#placement-key-checks-and-reports)
    - [Placement Generated Outputs](#placement-generated-outputs)
  - [Stage 5: Clock Tree Synthesis (CTS)](#stage-5-clock-tree-synthesis-cts)
    - [CTS Objective](#cts-objective)
    - [CTS Automated Tasks](#cts-automated-tasks)
    - [CTS Key Constraints and Strategies](#cts-key-constraints-and-strategies)
    - [CTS Key Checks and Reports](#cts-key-checks-and-reports)
    - [CTS Generated Outputs](#cts-generated-outputs)
  - [Stage 6: Routing](#stage-6-routing)
    - [Routing Objective](#routing-objective)
    - [Routing Automated Tasks](#routing-automated-tasks)
    - [Routing Strategies](#routing-strategies)
    - [Routing Key Checks and Reports](#routing-key-checks-and-reports)
      - [Pre-Routing Checks](#pre-routing-checks)
      - [Post-Routing Checks](#post-routing-checks)
    - [Routing Common Violations Handled](#routing-common-violations-handled)
    - [Routing Debug and Fix Methodology](#routing-debug-and-fix-methodology)
    - [Routing Generated Outputs](#routing-generated-outputs)
  - [Stage 7: Timing Optimization and ECO Fixes](#stage-7-timing-optimization-and-eco-fixes)
    - [Timing Optimization and ECO Fixes Objective](#timing-optimization-and-eco-fixes-objective)
    - [Timing Optimization and ECO Fixes Scope](#timing-optimization-and-eco-fixes-scope)
    - [Timing Optimization Techniques Used](#timing-optimization-techniques-used)
      - [Group Path Optimization](#group-path-optimization)
      - [Magnet Placement](#magnet-placement)
      - [Bound (Region) Creation](#bound-region-creation)
    - [CTS-Level Fixes (Skew and Hold)](#cts-level-fixes-skew-and-hold)
      - [Hold Violation Resolution](#hold-violation-resolution)
    - [Electrical Violation Fixes](#electrical-violation-fixes)
      - [Transition Violations](#transition-violations)
      - [Capacitance Violations](#capacitance-violations)
      - [Long Net Optimization](#long-net-optimization)
    - [ECO Automation Highlights](#eco-automation-highlights)
    - [Timing Optimization and ECO Fixes Key Checks and Reports](#timing-optimization-and-eco-fixes-key-checks-and-reports)
    - [Timing Optimization and ECO Fixes Generated Outputs](#timing-optimization-and-eco-fixes-generated-outputs)
- [Author](#author)
- [Disclaimer](#disclaimer)

## Project Overview

This is a stage-wise **Physical Design Implementation and automation project** developed using **Synopsys IC Compiler II (ICC2)**.  
This repository demonstrates **industry-style TCL scripting**, a **structured Physical Design flow**, and **signoff awareness** aligned with real-world **Netlist-to-GDSII ASIC methodology**.

The project is organized to reflect **production-level Physical Design practices**, where each PD stage is:
- Fully automated
- Independently debuggable
- Properly validated
- Version-controlled

## Project Objectives

- Automate the complete **Physical Design flow** using ICC2 TCL scripts  
- Follow **industry-standard directory organization**
- Enable **stage-level execution and debugging**
- Demonstrate awareness of **timing, power, and physical integrity**

## Tools and Technology

| Category | Details |
|----------|---------|
| Physical Design Tool | Synopsys IC Compiler II (ICC2) |
| Timing Analysis | Synopsys PrimeTime |
| RC Extraction | Synopsys StarRC |
| Technology Node | 28 nm |
| Design Type | Multi-voltage ASIC block |
| Flow | Netlist → GDSII |
| Scripting Language | TCL |

## Physical Design Flow (Stage-wise Automation)

## Stage 1: Import Design 

### Import Design Objective  
Create a clean ICC2 environment and import the design with all required dependencies.

### Import Design Automated Tasks
- Search path configuration  
- Reference NDM libraries (RVT/ HVT/ LVT/ SRAM)  
- Working library creation  
- Gate-level netlist import  
- Design linking  
- MMMC timing constraints loading  
- Scan DEF import  
- UPF (power intent) loading and commit  
- Initial design sanity checks  

## Import Design Generated Outputs
- Global Timing, Scan Chain, Design Mismatch, Multivolatge Design Report generation  
- Import design block

📁 **Script Location:** [`VNS_PD_Scripts/import_design.tcl`](VNS_PD_Scripts/import_design.tcl)

<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

## Stage 2: Floorplan 

### Floorplan Objective
Define the physical boundaries of the design by creating the core and die area, placing ports and macros, defining voltage regions, and preparing the design for placement and routing.

### Floorplan Automated Tasks
- Open imported design database and create floorplan block
- Core and die area definition using utilization, offset, and shape
- Floorplan initialization with site rows
- Port placement using pin guides and routing layer constraints
- Voltage area creation for multi-voltage power domains
- Macro-only placement with hierarchy-based grouping
- Macro spacing rule definition (horizontal and vertical)
- Keepout margin creation around hard macros
- Partial placement blockage generation
- Routing layer constraint setup
- Macro fixing and placement legalization
- Congestion analysis and reporting
- Tap cell and boundary cell insertion
- Physical design sanity checks
- Save floorplan block for next PD stage

## Floorplan Generated Outputs
- Floorplan design block (floorplan)
- Congestion report
- Boundary cell report
- Tap cell report
- Physical constraint report
- Pin placement report
  
📁 **Script Location:** [`VNS_PD_Scripts/fp.tcl`](VNS_PD_Scripts/fp.tcl)

<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

## Stage 3: Powerplan 

### Powerplan Objective
Implement a robust and DRC-clean power delivery network by creating power meshes, straps, rings, and standard cell rails to ensure reliable power integrity across all voltage domains.

### Powerplan Automated Tasks
- Sanity check for power and ground nets (VDD / VSS / VDDH)
- Open floorplan database and create power planning block
- Removal of existing PG strategies, patterns, regions, and routes
- Power net connectivity update and validation
- Definition of PG via master rules
- Identification and grouping of hard macros by power domain
- Creation of top-level power mesh on higher metal layers (M7 / M8)
- Power mesh strategy definition for core and voltage areas
- Creation of lower metal power straps (M2)
- Multi-layer PG strategy compilation with via rules
- Macro power ring creation for VDD, VSS, and VDDH
- Macro pin power connectivity using scattered pin strategy
- Standard cell power rail generation
- PG connectivity, missing via, and DRC checks
- Save power-planned design block for next PD stage

### Powerplan Key Power Structures Implemented
- **M7 and M8** : Global power mesh  
- **M2** : Local power straps  
- **M5 and M6** : Macro power rings  
- **M1** : Standard cell power rails  

### Powerplan Key Checks and Reports
- Power connectivity check  
- Missing PG via check  
- Power DRC verification  

### Powerplan Generated Outputs
- Power-planned design block (`powerplan`)
- Power connectivity report
- Missing via report
- Power DRC report

📁 **Script Location:** [`VNS_PD_Scripts/power.tcl`](VNS_PD_Scripts/power.tcl)

<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

## Stage 4: Placement 

### Placement Objective
Place and optimize standard cells while meeting timing, congestion, and physical constraints, ensuring a legal and high-quality placement ready for Clock Tree Synthesis (CTS).

### Placement Automated Tasks
- Creation of report directories for placement stages
- Pre-placement sanity checks:
  - Power connectivity verification
  - Multi-voltage design checks
  - Physical constraint and legality checks
  - QoR and utilization reporting
- Scan DEF reloading and MMMC timing constraints sourcing
- Placement-related application option tuning:
  - Congestion-driven placement
  - Timing-driven placement
  - Advanced legalization
- Clock network set as ideal during placement
- Routing layer constraint definition
- Hard macro fixing before standard cell placement
- Coarse placement and legalization
- Incremental placement refinement
- Multi-stage placement optimization:
  - Initial DRC placement
  - Initial timing optimization
  - Final placement
  - Final placement optimization
- Cell insertion analysis (buffers, inverters)
- Design block save at each major placement milestone

### Placement Key Checks and Reports
- Power connectivity and PG DRC checks
- Multi-voltage design checks
- Placement legality verification
- Congestion analysis
- Utilization reporting
- Global timing reports
- High fanout net analysis
- Constraint violation reports

### Placement Generated Outputs
- Rough legalized placement block  
- Initial DRC placement block  
- Initial optimization placement block  
- Final placement block  
- Final optimization placement block  
- Detailed placement and QoR reports  

📁 **Script Location:** [`VNS_PD_Scripts/place.tcl`](VNS_PD_Scripts/place.tcl)

<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

## Stage 5: Clock Tree Synthesis (CTS)

### CTS Objective
Build and optimize a balanced and low-skew clock distribution network that meets timing, transition, and signal integrity requirements across all operating corners and scenarios.

### CTS Automated Tasks
- Pre-CTS sanity checks and design validation
- Clock tree integrity and design consistency checks
- Derivation of clock cell reference list
- CTS cell control:
  - Exclude all library cells from CTS by default
  - Enable only selected LVT/RVT buffers and inverters
- Clock routing rule creation using non-default rules (NDR):
  - Double width and spacing
  - Controlled tapering
- Clock routing layer constraints definition
- Clock transition constraint setup across all corners
- Corner-based target skew definition
- Scenario-aware clock uncertainty setup
- Enable CRPR (Clock Reconvergence Pessimism Removal)
- Definition of clock balance points for selected clock endpoints
- Hold-fixing cell selection and control
- Clock tree build phase
- Clock tree routing phase
- Post-CTS timing analysis
- Aggressive hold-fix optimization
- Final CTS optimization and cleanup
- Save design block at each CTS milestone

### CTS Key Constraints and Strategies
- Target skew defined per corner
- Max clock transition limits enforced
- Scenario-based clock uncertainty
- Non-default routing rules for clocks
- Controlled CTS and hold-fixing cell usage
- CRPR enabled for accurate timing analysis

### CTS Key Checks and Reports
- Global timing report (post-CTS)
- Clock latency reports (per scenario)
- Clock DRC violation report
- Minimum pulse width violation report
- Maximum transition violation report
- Maximum capacitance violation report

### CTS Generated Outputs
- CTS build block (`build_clock_done`)
- CTS routed block (`route_clock_done`)
- Final CTS optimized block (`final_clock_opt_done`)
- Comprehensive CTS QoR reports

📁 **Script Location:** [`VNS_PD_Scripts/cts.tcl`](VNS_PD_Scripts/cts.tcl)

#<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

# Stage 6: Routing 

### Routing Objective
Perform timing-driven and signal-integrity-aware routing to achieve a fully connected, DRC-clean, and LVS-clean layout while preserving timing and power integrity.

### Routing Automated Tasks
- Pre-routing design and routability checks
- Pre-route design consistency verification
- Enable timing-driven routing at global, track, and detail levels
- Enable crosstalk-aware routing
- Enable signal integrity (SI) analysis
- Routing convergence tuning for DRC cleanup
- Antenna rule loading
- Automated routing flow:
  - Global routing
  - Track assignment
  - Detail routing
- Routing optimization
- Save routed design block
- Post-routing verification checks

### Routing Strategies
- Timing-driven routing enabled across all routing stages
- Crosstalk-aware routing for improved signal integrity
- Propagated clocks during routing
- Increased routing iterations for improved DRC convergence
- ECO-based routing for localized fixes

### Routing Key Checks and Reports

#### Pre-Routing Checks
- Routability check
- Pre-route design check

#### Post-Routing Checks
- Power and ground connectivity check
- Missing PG via check
- Power DRC check
- Routing DRC check
- LVS check (zero-error tolerance)

### Routing Common Violations Handled
- Metal shorts (same-net and different-net)
- Minimum spacing violations
- Minimum metal width and area violations
- Fat contact (via enclosure) violations
- Routing over restricted macro layers
- Missing vias in power and signal nets

### Routing Debug and Fix Methodology
- Manual GUI-based fixes for limited violations:
  - Metal stretching
  - Via replacement
  - Layer reassignment
- Batch fixes using TCL for large-scale violations
- ECO routing for targeted net-level LVS fixes
- Higher metal layer (M7) usage to avoid macro-level shorts

### Routing Generated Outputs
- Routed and optimized design block (`route_opt_done`)
- Pre-route check reports
- Post-route DRC reports
- PG connectivity reports
- LVS report (zero errors)

📁 **Script Location:** [`VNS_PD_Scripts/route.tcl`](VNS_PD_Scripts/route.tcl)

#<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>

# Stage 7: Timing Optimization and ECO Fixes 

### Timing Optimization and ECO Fixes Objective
Resolve setup, hold, transition, and capacitance violations using structured timing analysis, path-based optimization, and ECO-friendly Physical Design techniques across placement and CTS stages.

### Timing Optimization and ECO Fixes Scope
- Pre-placement and placement timing optimization
- CTS skew and hold violation fixing
- Post-CTS electrical violation cleanup
- ECO-based incremental fixes without disturbing clean regions

### Timing Optimization Techniques Used

#### Group Path Optimization
Logical classification of timing paths to enable focused optimization.

**Common Path Groups**
- Input → Register  
- Register → Register  
- Register → Output  
- Clock → Register  

**Why Used**
- Prioritizes critical paths
- Improves timing convergence
- Simplifies timing analysis and reporting

**Applied During**
- Placement optimization
- Timing analysis stages

#### Magnet Placement
Critical cells are pulled closer to reference objects (registers/macros) to reduce:
- Wire length
- Net delay
- Timing violations

**Use Case**
- Critical datapath optimization
- High-delay path cleanup

#### Bound (Region) Creation
Defines physical placement regions to control cell distribution.

**Bound Types Used**
- Hard bounds for strict placement control
- Exclusive bounds for macro-related logic

**Benefits**
- Prevents congestion
- Improves timing locality
- Controls ECO impact

### CTS-Level Fixes (Skew and Hold)

#### Hold Violation Resolution
- Capture clock delay insertion
- Local buffer insertion on clock pins
- Controlled delay using Low-VT buffers

**Verification**
- Post-fix timing reports confirm:
  - Positive hold slack
  - No setup degradation

**Alternative ECO Fix**
- Cell resizing using higher-delay variants when buffering is insufficient

### Electrical Violation Fixes

#### Transition Violations
- Automated VT swap:
  - RVT / LVT → HVT
- Reduces slew violations without upsizing

#### Capacitance Violations
- Driver cell upsizing
- Load-aware buffer insertion
- Net-length-based buffer strategy

#### Long Net Optimization
- Distance-driven buffer insertion
- Cell strength selected based on routing length

### ECO Automation Highlights
- Single-source violation reports:
  - Transition violations
  - Capacitance violations
- TCL-driven batch fixes
- Incremental legalization after ECO
- Minimal disturbance to clean timing paths

### Timing Optimization and ECO Fixes Key Checks and Reports
- Setup and hold timing reports
- Clock skew analysis
- Max transition violation report
- Max capacitance violation report
- Post-ECO timing verification

### Timing Optimization and ECO Fixes Generated Outputs
- ECO-fixed placement database
- Updated CTS timing reports
- Electrical violation reports
- Incrementally legalized design block

📁 **Script Location:** [`VNS_PD_Scripts/hook`](VNS_PD_Scripts/hook)

- [`group_path.tcl`](VNS_PD_Scripts/hook/group_path.tcl)
- [`magnet_placement.tcl`](VNS_PD_Scripts/hook/magnet_placement.tcl)
- [`bound_creation.tcl`](VNS_PD_Scripts/hook/bound_creation.tcl)
- [`cts_hold_fix.tcl`](VNS_PD_Scripts/hook/cts_hold_fix.tcl)
- [`vt_swap.tcl`](VNS_PD_Scripts/hook/vt_swap.tcl)
- [`cap_upsizing.tcl`](VNS_PD_Scripts/hook/cap_upsizing.tcl)
- [`buffer_insertion.tcl`](VNS_PD_Scripts/hook/buffer_insertion.tcl)

## Author

**Ravula Venkata Naga Sai**  
ASIC Physical Design Engineer  

**Expertise:**  
Nelist → GDSII | ICC2 | PrimeTime  

## Disclaimer

This project is intended **strictly for learning and demonstration purposes**.  
All scripts are **generic and reusable**.  
Tool-generated databases and proprietary data are **intentionally excluded**.

<p align="right">(<a href="#top">⬆️ Back to Top</a>)</p>


