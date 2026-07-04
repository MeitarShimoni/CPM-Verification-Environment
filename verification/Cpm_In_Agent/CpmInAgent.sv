//------------------------------------------------------------------------------
// FILE: CpmInAgent.sv
// AUTHOR: Meitar Shimoni
// DATE: 30/01/2026
//
// DESCRIPTION:
//    Agent for Input Streaming.
//------------------------------------------------------------------------------

class CpmInAgent extends uvm_agent;

    // Factory Registration
    `uvm_component_utils(CpmInAgent)

    // Class Properties
    CpmInDriver m_drv;
    CpmInMonitor m_mon;
    CpmInSequencer m_seqr;
    CpmInAgentConfig m_cfg; 

    // Constractor
    function new(string name = "CpmInAgent", uvm_component parent);
        super.new(name, parent);
    endfunction 

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(CpmInAgentConfig)::get(this, "", "m_cfg", m_cfg)) begin
            `uvm_fatal("AGT_CFG", "CpmInAgent: Could not get m_cfg from config_db")
        end

        // ✅ Provide VIF to children before they build
        uvm_config_db#(virtual input_streaming_if)::set(this, "m_mon", "m_vif", m_cfg.m_vif);
        // (optional) if you ever switch driver/seqr to config_db get:
        // uvm_config_db#(virtual input_streaming_if)::set(this, "m_drv",  "m_vif", m_cfg.m_vif);
        // uvm_config_db#(virtual input_streaming_if)::set(this, "m_seqr", "m_vif", m_cfg.m_vif);

        if (m_cfg.m_is_active == UVM_ACTIVE) begin
            m_drv  = CpmInDriver    ::type_id::create("m_drv",  this);
            `uvm_info("CpmInAgent", "Starting to create m_seqr...", UVM_LOW)
            m_seqr = CpmInSequencer ::type_id::create("m_seqr", this);
            `uvm_info("CpmInAgent", "Finished creating m_seqr", UVM_LOW)
        end
        m_mon = CpmInMonitor::type_id::create("m_mon", this);
    endfunction


    // Connect Phase
    virtual function void connect_phase(uvm_phase phase);
        // super.connect_phase(phase);

        m_mon.m_vif = m_cfg.m_vif;
        if (m_cfg.m_is_active == UVM_ACTIVE) begin
            m_drv.m_vif = m_cfg.m_vif;
            m_seqr.m_vif = m_cfg.m_vif;
            // Connecting the Driver to the Sequencer via 
            m_drv.seq_item_port.connect(m_seqr.seq_item_export);
        end
        
    endfunction

endclass
