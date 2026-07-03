// import uvm_pkg::*;
// `include "uvm_macros.svh"

// import CpmInAgentPkg::*;
// import CpmOutAgentPkg::*;
// import CpmRegAgentPkg::*;


class CpmEnv extends uvm_env;

    // Factory Registration
    `uvm_component_utils(CpmEnv)

    // Properties
    CpmScoreboard m_sb;
    // Streaming Input Agent 
    CpmInAgent m_in_agent;
    // Streaming Output Agent
    CpmOutAgent m_out_agent;
    // Register Control Agent
    CpmRegAgent m_reg_agent;
    // Environment Configuration
    CpmEnvConfig m_env_cfg;

    // Reference Model
    RefModel m_ref_model;
    CoverageCollector m_cov_collector; // NEWWWWW

    // RAL
    cpm_reg_map    m_regmodel;
    cpm_reg_adapter                   m_reg_adapter;
    uvm_reg_predictor#(CpmRegTrans)  m_reg_predictor;


    // Constractor
    function new(string name = "CpmEnv", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  `uvm_info(get_type_name(), "inside build phase...", UVM_LOW)

  // Get env cfg (must be set by test)
  if (!uvm_config_db#(CpmEnvConfig)::get(this, "", "m_env_cfg", m_env_cfg)) begin
    `uvm_fatal("ENV_CFG", "CpmEnv: Missing m_env_cfg in config_db")
  end

  // Push agent cfgs to each agent through config_db (standard)
  uvm_config_db#(CpmInAgentConfig )::set(this, "m_in_agent",  "m_cfg", m_env_cfg.m_in_agent_cfg);
  uvm_config_db#(CpmOutAgentConfig)::set(this, "m_out_agent", "m_cfg", m_env_cfg.m_out_agent_cfg);
  uvm_config_db#(CpmRegAgentConfig)::set(this, "m_reg_agent", "m_cfg", m_env_cfg.m_reg_agent_cfg);

  // Now create agents
  `uvm_info(get_type_name(), "Building input agent", UVM_LOW)
  m_in_agent  = CpmInAgent::type_id::create("m_in_agent", this);

  `uvm_info(get_type_name(), "Building output agent", UVM_LOW)
  m_out_agent = CpmOutAgent::type_id::create("m_out_agent", this);

  `uvm_info(get_type_name(), "Building register control agent", UVM_LOW)
  m_reg_agent = CpmRegAgent::type_id::create("m_reg_agent", this);

  `uvm_info(get_type_name(), "Building scoreboard", UVM_LOW)
  m_sb = CpmScoreboard::type_id::create("m_sb", this);

  m_ref_model = RefModel::type_id::create("m_ref_model", this);

  // ---------------- RAL build ----------------
  m_regmodel = cpm_reg_map::type_id::create("m_regmodel", this);
  m_regmodel.build();
  m_regmodel.lock_model();

  m_reg_adapter   = cpm_reg_adapter::type_id::create("m_reg_adapter");
  m_reg_predictor = uvm_reg_predictor#(CpmRegTrans)::type_id::create("m_reg_predictor", this);

  m_cov_collector = CoverageCollector::type_id::create("m_cov_collector", this); // NEWWWWW
  // expose regmodel to sequences + refmodel
  uvm_config_db#(cpm_reg_map)::set(this, "*", "regmodel", m_regmodel);
endfunction


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_type_name(), "inside connect phase...", UVM_LOW)
        
        // INPUT -> RefModel
        m_in_agent.m_mon.ap.connect(m_ref_model.in_ap);
        // m_in_agent.m_mon.m_regmodel = this.m_regmodel; // to see drop functionality
        // m_in_agent.m_mon.ap.connect(m_cov_collector.analysis_export);

        // RefModel -> expected
        m_ref_model.out_ap.connect(m_sb.m_expected_export);

        // OUTPUT -> actual
        m_out_agent.m_mon.ap.connect(m_sb.m_actual_export);

        // OUTPUT -> coverage (so packets are sampled for coverage)
        m_in_agent.m_mon.ap.connect(m_cov_collector.analysis_export);

        // ---------------- RAL connect ----------------
        // 1) RAL frontdoor goes through reg agent sequencer
        m_regmodel.default_map.set_sequencer(m_reg_agent.m_seqr, m_reg_adapter);

        // 2) predictor updates RAL mirror from bus traffic
        m_reg_predictor.map     = m_regmodel.default_map;
        m_reg_predictor.adapter = m_reg_adapter;
        m_regmodel.default_map.set_auto_predict(0); // since you use predictor

        // connect reg monitor -> predictor
        m_reg_agent.m_mon.ap.connect(m_reg_predictor.bus_in);
        m_cov_collector.m_regmodel = this.m_regmodel; // NEWWWWW

    endfunction


endclass


