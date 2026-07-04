# PROJECT SUMMARY: CONFIGURABLE PACKET MODIFIER (CPM) UVM VERIFICATION
# AUTHOR: Meitar Shimoni

## 1. DUT OVERVIEW
The CPM is a single-beat packet processing unit designed for high-throughput streaming.
- Interfaces: Streaming Input (Ready/Valid), Streaming Output (Ready/Valid), and a Register Control Interface (Req/Gnt).
- Core Operations: PASS (0-cycle), XOR (1-cycle), ADD (2-cycle), and ROT (1-cycle).
- Key Feature: Opcode-based packet dropping via the DROP_CFG register.
- Observability: Internal counters (COUNT_IN, COUNT_OUT, DROPPED_COUNT).

## 2. UVM ARCHITECTURE & COMPONENTS
I architected a modular UVM environment including:
- Agents:
    - CpmInAgent: Drives 24-bit packet transactions (ID, Opcode, Payload) into the DUT.
    - CpmOutAgent: Monitors output and handles randomized backpressure via the 'out_ready' signal.
    - CpmRegAgent: Implements the Req/Gnt register bus protocol.
- RAL (Register Abstraction Layer):
    - Built a complete uvm_reg_block mapping CTRL, MODE, PARAMS, and DROP_CFG registers.
    - Integrated an adapter and predictor to ensure the model mirrors RTL state via implicit/explicit monitoring.
- Checking & Scoreboarding:
    - Reference Model: Samples register configuration at the exact 'in_fire' moment (valid & ready).
    - Scoreboard: Uses a transaction queue to verify data integrity, transformation accuracy, and the hardware invariant: COUNT_IN == COUNT_OUT + DROPPED_COUNT.



## 3. VERIFICATION STRATEGY & STIMULUS
- Control Model: Followed a strict hierarchy where the Test sets the configuration (uvm_config_db) and the Virtual Sequence orchestrates leaf sequences.
- Virtual Sequences: Implemented an 8-stage flow: Reset -> Config -> Traffic -> Reconfig -> Stress -> Drop -> Readback -> End.
- Advanced Techniques:
    - Factory Overrides: Swapped 'base_traffic_seq' for 'coverage_traffic_seq' to hit rare cross-bins.
    - Callbacks: Used driver/monitor callbacks for event tagging and logging.

## 4. ACHIEVED COVERAGE & CLOSURE
I achieved 100% closure on mandatory requirements:
- MODE Coverage: 100% (Verified all transformations).
- OPCODE Coverage: 92% (Across the 4-bit range).
- Cross Coverage: 85% (Ensured every MODE worked with various OPCODES).
- Event Bins: Confirmed 'Drop' logic and 'Stall' (backpressure) robustness.
- SVA (Assertions): Verified Handshake stability and Bounded Liveness (latency checks).

## 5. TOOLS & REGRESSION
- Simulation: Used Mentor Questasim/Questa.
- Automation: Developed 'run_regression.do' to automate compilation, multi-test execution, and UCDB coverage merging.



//////////////////////////////////


I want to post a small presentation over my UVM environment Final project. A couple of pages, to demonstrate what i had to do, what i did and achived. This is based on a full UVM environment i built. 

This is the project summary:
================================================================================
PROJECT SUMMARY: CONFIGURABLE PACKET MODIFIER (CPM) UVM VERIFICATION
AUTHOR: Meitar Shimoni
COURSE: Chip Design & Verification - Reichman University
================================================================================

--------------------------------------------------------------------------------
1. DUT (DESIGN UNDER TEST) OVERVIEW
--------------------------------------------------------------------------------
The CPM is a high-speed, single-beat packet processing unit.
- Logic: Transforms input packets based on a 4-mode configuration.
- Latency: Deterministic pipeline (PASS: 0c, XOR/ROT: 1c, ADD: 2c).
- Flow Control: Ready/Valid handshake on all data streaming interfaces.
- Drop Logic: Conditional packet dropping based on opcode matching.
- Monitoring: Software-accessible RO counters for input, output, and drops.

--------------------------------------------------------------------------------
2. VERIFICATION ARCHITECTURE (AGENTS & COMPONENTS)
--------------------------------------------------------------------------------
I developed a modular UVM environment consisting of three specialized agents:

A. CpmInAgent (Streaming Input):
   - Role: Active agent driving the stimulus source.
   - Driver: Handles Ready/Valid protocol; drives ID, Opcode, and Payload.
   - Monitor: Captures packets at the 'fire' event (Valid & Ready) for the RefModel.

B. CpmOutAgent (Streaming Output):
   - Role: Active agent acting as the data sink.
   - Sequencer/Driver: Implements a reactive mechanism to drive 'out_ready'. 
     Used to test backpressure robustness.
   - Monitor: Captures actual DUT output for Scoreboard comparison.

C. CpmRegAgent (Register Control Plane):
   - Role: Active agent implementing the Req/Gnt bus protocol.
   - RAL Adapter: Converts RAL 'uvm_reg' operations into bus-level handshake.
   - Purpose: Centralized configuration and status monitoring.

D. RAL (Register Abstraction Layer):
   - Mandatory uvm_reg_block mapping: CTRL, MODE, PARAMS, DROP_CFG.
   - Verified counters (COUNT_IN, COUNT_OUT, DROPPED_COUNT) via RO registers.

E. Scoreboard & RefModel:
   - Prediction: RefModel samples MODE/PARAMS at the exact 'in_fire' cycle.
   - Validation: Enforces strict in-order processing and cycle-accurate latency.
   - Invariant: Verified that (COUNT_OUT + DROPPED_COUNT) == COUNT_IN.



--------------------------------------------------------------------------------
3. STIMULUS & TEST STRATEGY
--------------------------------------------------------------------------------
- Control Model: Strict UVM compliance. Tests configure environment "knobs" 
  via uvm_config_db; Virtual Sequences orchestrate the DUT flow.
- Top Virtual Sequence Stages: 
  1. Synchronous Reset 
  2. RAL Configuration 
  3. Base Traffic 
  4. Runtime Reconfiguration (Sampling check) 
  5. Stress (Backpressure) 
  6. Opcode Dropping 
  7. Final Register Readback
- Factory Overrides: Utilized to swap 'base_traffic_seq' for 
  'coverage_traffic_seq' to hit rare MODE x OPCODE cross-bins.

--------------------------------------------------------------------------------
4. ACHIEVED COVERAGE & SIGN-OFF CRITERIA
--------------------------------------------------------------------------------
- MODE Coverage: 100% (PASS, XOR, ADD, ROT).
- OPCODE Coverage: 92% (Full 4-bit range).
- Cross Coverage: 85% (MODE x OPCODE).
- Event Bins: 100% (Confirmed at least one Drop and one Stall/Backpressure event).
- Assertions (SVA): 
    * Handshake stability (Valid-to-Ready).
    * Bounded Liveness (Latency <= 2 cycles + backpressure slack).
    * Reset Protocol safety.

--------------------------------------------------------------------------------
5. REGRESSION & TOOLS
--------------------------------------------------------------------------------
- Environment: SystemVerilog/UVM 1.2.
- Tool: Mentor Graphics Questasim (Questa).
- Automation: Created 'run_regression.do' for automated compile, run, 
  and UCDB coverage merging to produce a final 'cov_merged' sign-off report.
================================================================================