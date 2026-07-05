// class CpmOutDriver extends uvm_driver #(CpmOutTransaction);

//     // Factory Registration
//     `uvm_component_utils(CpmOutDriver)
//     virtual output_streaming_if m_vif;

//     // Constructor
//     function new(string name = "CpmOutDriver", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     // Build Phase
//     virtual function void build_phase(uvm_phase phase);
//         if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_vif", m_vif)) begin
//             `uvm_fatal("DRIVER", "Could not get interface!")
//         end
//     endfunction

//     // Run Phase
//     virtual task run_phase(uvm_phase phase);
//         CpmOutTransaction req_item;

//         // 1. Initialize default state
//         m_vif.drv_cb.out_ready <= 1'b0;

//         forever begin
//             seq_item_port.get_next_item(req_item); 

//             // 2. Inject Backpressure (Delay)
//             // Wait for the randomized number of clock cycles before asserting ready.
//             // If delay is 0, this loop is skipped and we assert ready immediately.
//             if (req_item.delay > 0) begin
//                 repeat(req_item.delay) @(m_vif.drv_cb);
//                 `uvm_info(get_type_name(), $sformatf("Injected %0d cycles of backpressure", req_item.delay), UVM_LOW)
//             end

//             // 3. Drive Ready High
//             m_vif.drv_cb.out_ready <= 1'b1;

//             // 4. Wait for Handshake (Valid == 1)
//             // We loop over clock edges until the DUT signals valid data.
//             do begin
//                 @(m_vif.drv_cb);
//             end while (m_vif.drv_cb.out_valid !== 1'b1);

//             // 5. Complete Transfer & Deassert Ready
//             // The handshake occurred on the clock edge above.
//             // We immediately pull ready low to guarantee we only consume ONE item.
//             m_vif.drv_cb.out_ready <= 1'b0;

//             seq_item_port.item_done();
//         end
//     endtask

// endclass




//// FOR THE DROP TEST

class CpmOutDriver extends uvm_driver #(CpmOutTransaction);

    `uvm_component_utils(CpmOutDriver)

    virtual output_streaming_if m_vif;

    function new(string name = "CpmOutDriver", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_vif", m_vif)) begin
            `uvm_fatal("DRIVER", "Could not get interface!")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        CpmOutTransaction req_item;

        m_vif.drv_cb.out_ready <= 1'b0;

        forever begin
            seq_item_port.get_next_item(req_item);

            if (req_item.delay > 0) begin
                m_vif.drv_cb.out_ready <= 1'b0;
                repeat(req_item.delay) @(m_vif.drv_cb);
                `uvm_info(get_type_name(), $sformatf(
                    "Injected %0d cycles of backpressure",
                    req_item.delay
                ), UVM_LOW)
            end

            m_vif.drv_cb.out_ready <= 1'b1;

            // Hold ready high for one cycle only
            @(m_vif.drv_cb);

            m_vif.drv_cb.out_ready <= 1'b0;

            seq_item_port.item_done();
        end
    endtask

endclass