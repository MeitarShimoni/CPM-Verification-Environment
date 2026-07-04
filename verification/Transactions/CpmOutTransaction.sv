class CpmOutTransaction extends uvm_sequence_item;
    rand int delay;
    rand int duration;
    `uvm_object_utils_begin(CpmOutTransaction)
        `uvm_field_int(delay, UVM_ALL_ON)
        `uvm_field_int(duration, UVM_ALL_ON)
    `uvm_object_utils_end

        // NOTE:
        // duration MUST be >= 1, otherwise the driver does:
        //   out_ready<=1; repeat(0); out_ready<=0;
        // in the same timestep (NBA), and out_ready never goes high.
        // That can deadlock the DUT (no out_fire) -> buffer_full -> in_ready stuck low.
        constraint delay_c    { delay    inside {[0:3]}; }
        // Keep duration at 1 so each out-seq item maps to (at most) one output accept.
        // This avoids the driver consuming multiple outputs per item and then timing out
        // on remaining items (OUT_VALID_TO).
        constraint duration_c { duration inside {[1:1]}; }


endclass