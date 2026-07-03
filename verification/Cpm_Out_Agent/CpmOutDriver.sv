

// class CpmOutDriver extends uvm_driver #(CpmOutTransaction);;

//     // Factory Registration
//     `uvm_component_utils(CpmOutDriver)

//     // Callback if needed

//     // Virtual Interface
//     virtual output_streaming_if m_vif;

//     // Constractor
//     function new(string name = "CpmOutDriver", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     // Build Phase
//     virtual function void build_phase(uvm_phase phase);
        
//         // super.build_phase(phase);
//         if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_vif", m_vif)) begin
//             `uvm_fatal("DRIVER", "Could not get interface!")
//         end
//     endfunction

//     // Run Phase
//     virtual task run_phase(uvm_phase phase);
//         CpmOutTransaction req_item;
//         int unsigned wait_cycles;
//         localparam int unsigned OUT_VALID_TIMEOUT_CYCLES = 5000;

//         m_vif.drv_cb.out_ready <= 1'b0;

//         forever begin
//             seq_item_port.get_next_item(req_item); // מחכה לפקודה מהסיקוונס [cite: 255]

//             // IMPORTANT:
//             // If we generate ready pulses while out_valid=0, the pulse is "wasted".
//             // That can make the test finish with exp_leftovers (e.g. IN:10 OUT:9),
//             // because some outputs never get accepted.
//             // Therefore, each sequence item is consumed only when there's an output to take.
//             wait_cycles = 0;
//             while (m_vif.drv_cb.out_valid !== 1'b1) begin
//                 @(m_vif.drv_cb);

//                 // Keep idle during reset
//                 if (m_vif.rst === 1'b1) begin
//                     m_vif.drv_cb.out_ready <= 1'b0;
//                     wait_cycles = 0;
//                     continue;
//                 end

//                 wait_cycles++;
//                 if (wait_cycles >= OUT_VALID_TIMEOUT_CYCLES) begin
//                     `uvm_error("OUT_VALID_TO",
//                                $sformatf("Timeout waiting for out_valid (%0d cycles). Either DUT didn't produce output or CTRL.ENABLE went low.",
//                                          OUT_VALID_TIMEOUT_CYCLES))
//                     break;
//                 end
//             end

//             // If we timed out, don't try to apply a backpressure pattern for this item.
//             if (wait_cycles >= OUT_VALID_TIMEOUT_CYCLES) begin
//                 seq_item_port.item_done();
//                 continue;
//             end

//             // One handshake per item: delay then assert ready until we see (valid && ready).
//             m_vif.drv_cb.out_ready <= 1'b0;
//             repeat(req_item.delay) @(m_vif.drv_cb);

//             m_vif.drv_cb.out_ready <= 1'b1;
//             begin
//               int unsigned hs_cycles = 0;
//               while (!(m_vif.drv_cb.out_valid === 1'b1 && m_vif.drv_cb.out_ready === 1'b1)) begin
//                 @(m_vif.drv_cb);
//                 hs_cycles++;
//                 if (hs_cycles >= 20) break; // avoid infinite wait
//               end
//             end
//             @(m_vif.drv_cb);
//             m_vif.drv_cb.out_ready <= 1'b0;

//             seq_item_port.item_done();
//         end
//     endtask

// endclass



class CpmOutDriver extends uvm_driver #(CpmOutTransaction);;

    // Factory Registration
    `uvm_component_utils(CpmOutDriver)
    virtual output_streaming_if m_vif;

    // Constractor
    function new(string name = "CpmOutDriver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_vif", m_vif)) begin
            `uvm_fatal("DRIVER", "Could not get interface!")
        end
    endfunction

    // Run Phase
    virtual task run_phase(uvm_phase phase);
        CpmOutTransaction req_item;

        m_vif.drv_cb.out_ready <= 1'b0;

        forever begin
            seq_item_port.get_next_item(req_item); 

            // Assert 1 at posedge 
            @(posedge m_vif.clk) m_vif.drv_cb.out_ready <= 1'b1;


            while (m_vif.drv_cb.out_valid !== 1'b1) begin
                @(m_vif.drv_cb);
            end

            @(m_vif.drv_cb);
            m_vif.drv_cb.out_ready <= 1'b0;

            seq_item_port.item_done();
        end
    endtask

endclass
