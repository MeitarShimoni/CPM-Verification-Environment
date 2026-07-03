class CpmOutAgent extends uvm_agent;

    // Factory Registration
    `uvm_component_utils(CpmOutAgent)

    // Class Properties
    CpmOutDriver m_drv;
    CpmOutMonitor m_mon;
    CpmOutSequencer m_seqr; // NEW
    CpmOutAgentConfig m_cfg;

    // Constractor
    function new(string name = "CpmOutAgent", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    // Build Phase
    virtual function void build_phase(uvm_phase phase);

        if (!uvm_config_db#(CpmOutAgentConfig)::get(this, "", "m_cfg", m_cfg)) begin
            `uvm_fatal("AGT_CFG", "CpmOutAgent: Missing m_cfg in config_db")
        end

        uvm_config_db#(virtual output_streaming_if)::set(this, "m_drv", "m_vif", m_cfg.m_vif);

        if (m_cfg.m_is_active == UVM_ACTIVE) begin
            m_drv = CpmOutDriver::type_id::create("m_drv", this);
            `uvm_info("CpmInAgent", "Starting to create m_seqr...", UVM_LOW)
            m_seqr = CpmOutSequencer ::type_id::create("m_seqr", this); // NEW
        end
        m_mon = CpmOutMonitor::type_id::create("m_mon", this);
    endfunction

    // Connect Phase
    virtual function void connect_phase(uvm_phase phase);
        // super.connect_phase(phase);
        m_mon.m_vif = m_cfg.m_vif;

        if (m_cfg.m_is_active == UVM_ACTIVE) begin
            m_drv.m_vif = m_cfg.m_vif;
            m_seqr.m_vif = m_cfg.m_vif; // NEW
            // Connecting the Driver to the Sequencer via 
            m_drv.seq_item_port.connect(m_seqr.seq_item_export); // NEW
        end
    endfunction

endclass

