class CpmRegAgent extends uvm_agent;

  `uvm_component_utils(CpmRegAgent)

  CpmRegDriver     m_drv;
  CpmRegMonitor    m_mon;
  CpmRegSequencer  m_seqr;
  CpmRegAgentConfig m_cfg;

  function new(string name="CpmRegAgent", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);

    // Get configuration from config_db
    if (!uvm_config_db#(CpmRegAgentConfig)::get(this, "", "m_cfg", m_cfg)) begin
      `uvm_fatal("REG_AGT_CFG", "CpmRegAgent: Could not get m_cfg from config_db")
    end

    // Check if the virtual interface in the config is valid
    if (m_cfg.m_vif == null) begin
      `uvm_fatal("REG_AGT_VIF", "CpmRegAgent: m_cfg.m_vif is null")
    end

    uvm_config_db#(virtual reg_ctrl_if)::set(this, "m_drv",  "m_vif", m_cfg.m_vif);
    uvm_config_db#(virtual reg_ctrl_if)::set(this, "m_mon",  "m_vif", m_cfg.m_vif);
    uvm_config_db#(virtual reg_ctrl_if)::set(this, "m_seqr", "m_vif", m_cfg.m_vif);


    if (m_cfg.m_is_active == UVM_ACTIVE) begin
      m_drv  = CpmRegDriver::type_id::create("m_drv", this);
      m_seqr = CpmRegSequencer::type_id::create("m_seqr", this);
    end
    m_mon = CpmRegMonitor::type_id::create("m_mon", this);
  endfunction

  // Manually connect the sequencer to the driver (if active)
  virtual function void connect_phase(uvm_phase phase);
    m_mon.m_vif = m_cfg.m_vif;
    if (m_cfg.m_is_active == UVM_ACTIVE) begin 
      m_drv.m_vif = m_cfg.m_vif;
      m_seqr.m_vif = m_cfg.m_vif;
      m_drv.seq_item_port.connect(m_seqr.seq_item_export);
    end
  endfunction

endclass

