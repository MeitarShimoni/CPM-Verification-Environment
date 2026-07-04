//------------------------------------------------------------------------------
// FILE: CpmInMonitor.sv
// AUTHOR: Meitar Shimoni
// DATE: 30/01/2026
//
// DESCRIPTION:
//    Monitoring the Input Streaming.
//------------------------------------------------------------------------------

class CpmInMonitor extends uvm_monitor;
    
    // Factory Registration
    `uvm_component_utils(CpmInMonitor)

    virtual input_streaming_if m_vif;

    uvm_analysis_port#(CpmPacket) ap;

    // Constractor
    function new(string name = "CpmInMonitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // build phase
    virtual function void build_phase(uvm_phase phase);
        // super.build_phase(phase);
        ap = new("ap", this);

        if (!uvm_config_db#(virtual input_streaming_if)::get(this, "", "m_vif", m_vif)) begin
            `uvm_fatal("MON_VIF_NULL", "CpmInMonitor: Could not get m_vif from config_db")
        end
        
    endfunction

    virtual task run_phase(uvm_phase phase);
        CpmPacket packet;

        packet = CpmPacket::type_id::create("packet", this);
        
        forever begin

            @(m_vif.mon_cb);
            
            if (m_vif.mon_cb.in_valid && m_vif.mon_cb.in_ready) begin
                `uvm_info("CpmInMonitor:", "SAW Transaction!", UVM_DEBUG)
                packet = CpmPacket::type_id::create("packet", this);
                
                // Sampeling the data into the object
                packet.id = m_vif.mon_cb.in_id;
                packet.opcode = m_vif.mon_cb.in_opcode;
                packet.payload = m_vif.mon_cb.in_payload;

                // send the the rest of the environment
                ap.write(packet);
                `uvm_info("CpmInMonitor: Saw", packet.summary(), UVM_DEBUG)
            end
        end
    endtask

endclass
