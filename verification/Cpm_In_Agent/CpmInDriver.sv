//------------------------------------------------------------------------------
// FILE: CpmInDriver.sv
// AUTHOR: Meitar Shimoni
// DATE: 16/02/2026
//
// DESCRIPTION:
//    Driver for Input Streaming - Fixed Handshake Logic.
//------------------------------------------------------------------------------

class CpmInDriver extends uvm_driver#(CpmPacket);

    // Factory Registration
    `uvm_component_utils(CpmInDriver)

    // Virtual Interface
    virtual input_streaming_if m_vif;

    // Constructor
    function new(string name = "CpmInDriver", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Run Phase
    virtual task run_phase(uvm_phase phase);
        CpmPacket packet;
        int unsigned ready_wait_cycles;
        localparam int unsigned IN_READY_TIMEOUT_CYCLES = 100;
        
        // Initialize Signals to safe state [cite: 49, 50]
        m_vif.drv_cb.in_valid   <= 1'b0;
        m_vif.drv_cb.in_id      <= 'd0;
        m_vif.drv_cb.in_opcode  <= 'd0;
        m_vif.drv_cb.in_payload <= 'd0;

        forever begin
            // Keep idle during reset (prevents hanging on X/0 ready)
            while (m_vif.rst === 1'b1) begin
                @(m_vif.drv_cb);
                m_vif.drv_cb.in_valid <= 1'b0;
            end

            // Wait for a new item from sequencer
            seq_item_port.get_next_item(packet);
            
            `uvm_info("CpmInDriver", $sformatf("Driving packet: %s", packet.summary()), UVM_MEDIUM)
        
            // Align to clocking block edge before driving
            @(m_vif.drv_cb);

            // Assert valid and drive packet fields
            m_vif.drv_cb.in_valid   <= 1'b1;
            m_vif.drv_cb.in_id      <= packet.id;
            m_vif.drv_cb.in_opcode  <= packet.opcode;
            m_vif.drv_cb.in_payload <= packet.payload;

            ready_wait_cycles = 0;
            @(posedge m_vif.clk);
 
            do begin
                @(m_vif.drv_cb);

                // If reset asserted mid-handshake, abort cleanly
                if (m_vif.rst === 1'b1) begin
                    m_vif.drv_cb.in_valid <= 1'b0;
                    break;
                end

                ready_wait_cycles++;
                if (ready_wait_cycles >= IN_READY_TIMEOUT_CYCLES) begin
                    `uvm_error("IN_READY_TO",$sformatf("Timeout waiting for in_ready (%0d cycles). Likely causes: CTRL.ENABLE=0, output never asserts out_ready (no out_fire), or DUT stuck in reset.",
                                         IN_READY_TIMEOUT_CYCLES));
                    break;
                end
            end while (m_vif.drv_cb.in_ready !== 1'b1);

            m_vif.drv_cb.in_valid <= 1'b0;

            seq_item_port.item_done();
        end
    endtask

endclass