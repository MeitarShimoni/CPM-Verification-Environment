




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