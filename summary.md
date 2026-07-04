




### 1. Stress Test (`CpmStressVirtualSequence`)

**Objective:** To validate the Configurable Packet Modifier's (CPM) stability and data integrity under concurrent input/output traffic and artificial backpressure. This test ensures that the internal buffers and pipelines correctly handle parallel operations without stalling, dropping, or corrupting packets.

**Execution Flow & Verification Strategy:**

* **System Initialization:** Drives a hardware reset sequence (`rst_seq`) via the input sequencer to establish a clean, known starting state, followed by a `50ns` stabilization delay.
* **RAL Configuration:** Utilizes the UVM Register Abstraction Layer (RAL) to safely configure the DUT's operational parameters prior to activation. 
  * Sets the `MODE` register to `2'b01` (XOR Mode).
  * Applies a parameter mask by writing `16'h00FF` to `PARAMS.MASK`.
* **Core Activation & Integrity Check:** Writes `32'h1` to the `CTRL` register to formally enable the CPM. This is immediately followed by a read-back assertion to verify AHB/APB register access and write integrity.
* **Parallel Traffic Generation (Stress Condition):** Employs a `fork...join` block to simulate asynchronous, concurrent interface activity, stressing the DUT's internal architecture:
  * **Input Thread:** Injects a continuous burst of 20 stimulus packets via the input sequencer.
  * **Output Thread:** Introduces an artificial `200ns` stall before initiating the output sequence for 20 packets. This deliberate delay tests the DUT's backpressure handling and validates FIFO/buffer thresholds.
* **Invariant Validation:** Concludes by invoking `check_invariants()` to evaluate DUT hardware counters and ensure structural stability post-traffic execution.



BUGs and Challenges:


### Bug Report & Resolution: Coverage Collector Stalls Missing

**Symptom:**
The Functional Coverage report showed 0% hits for the `was_stalled` coverpoint (downstream backpressure), despite transaction logs clearly indicating that packets were experiencing stalls (`was_stalled = 1`) at the output interface.

**Root Cause Analysis:**
An architectural mismatch in the TLM (Transaction Level Modeling) connections within `CpmEnv.sv`. 
The `CoverageCollector`'s analysis export was connected exclusively to the Input Agent's monitor (`m_in_agent.m_mon.ap`). Because the Input Monitor only observes the input interface, it has no visibility into downstream backpressure events occurring at the output interface. Consequently, the coverage collector only received packets where `was_stalled == 0`.

**Resolution:**
To ensure the Coverage Collector has a complete view of both input-specific events (like dropped packets) and output-specific events (like stalls), the collector's architecture was updated to accept multiple streams:

1. **Updated `CoverageCollector.sv`:** Utilized `uvm_analysis_imp_decl` macros to create two distinct analysis ports (`analysis_export_in` and `analysis_export_out`).
2. **Updated `CpmEnv.sv` Connections:**
   - Routed `m_in_agent.m_mon.ap` to `m_cov_collector.analysis_export_in` (Captures opcodes and `was_dropped` flags).
   - Routed `m_out_agent.m_mon.ap` to `m_cov_collector.analysis_export_out` (Captures `was_stalled` backpressure flags).

This ensures all edge cases—both at the ingress and egress of the DUT—are accurately sampled without losing data or relying on a single, limited vantage point.