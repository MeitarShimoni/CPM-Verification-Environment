
class CpmBaseTest extends uvm_test;

    // Factory Registration
    `uvm_component_utils(CpmBaseTest)

    // Properties
    CpmEnv m_env;
    // CpmEnvConfig m_env_cfg;
    CpmVirtualSequence m_vseq;

    // Virtual Sequence

    // Virtual interfaces
    virtual input_streaming_if m_in_vif;
    virtual output_streaming_if m_out_vif;
    virtual reg_ctrl_if m_reg_vif;

    // Constractor
    function new(string name = "CpmBaseTest", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_type_name(), "inside Build Phase!", UVM_LOW)

        // Get Configurations (Set on the Tb Top)
        if (!uvm_config_db#(virtual input_streaming_if)::get(this, "", "m_in_vif", m_in_vif)) 
            `uvm_fatal(get_type_name(), "could not fetch input_streaming_if!")

        if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_out_vif", m_out_vif)) 
            `uvm_fatal(get_type_name(), "could not fetch output_streaming_if!")

        if (!uvm_config_db#(virtual reg_ctrl_if)::get(this, "", "m_reg_vif", m_reg_vif)) 
            `uvm_fatal(get_type_name(), "could not fetch reg_ctrl_if!")

        create_and_config_env();
        create_and_config_agents(UVM_ACTIVE, UVM_ACTIVE, UVM_ACTIVE);

        uvm_config_db#(CpmEnvConfig)::set(this, "m_env", "m_env_cfg", m_env.m_env_cfg);

        // set_type_override_by_type(CpmSequence1::get_type(), CpmCoverageSequence::get_type()); 
        m_vseq = CpmVirtualSequence::type_id::create("m_vseq", this);
        
        // Creating The CallBacks
        // Cpm_Error_Injection_Cb m_cb;
        // m_cb = Cpm_Error_Injection_Cb::type_id::create("m_cb");
        // `uvm_callbacks#(CpmInDriver, CpmDriverCb)::add(m_env._m_in_agent.m_driver, m_cb);

    endfunction

    // ======================== Connect Phase ======================== 
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        m_vseq.m_in_seqr = m_env.m_in_agent.m_seqr; // connect to agent
        m_vseq.m_out_seqr = m_env.m_out_agent.m_seqr; // NEW
        m_vseq.m_reg_seqr = m_env.m_reg_agent.m_seqr; // connect to reg agent 

    endfunction

    virtual function void end_of_elaboration_phase (uvm_phase phase);
        uvm_top.print_topology();
        uvm_test_done.set_drain_time(this, 200ns); // Debug
    endfunction


    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        
        m_vseq.m_regmodel = m_env.m_regmodel;
        `uvm_info("TEST", "Starting Virtual Sequence...", UVM_LOW)
        m_vseq.start(null);
        `uvm_info("TEST", "Virtual Sequence FINISHED!", UVM_LOW) // If you don't see this, the vseq is the hang
       #100;
        phase.drop_objection(this);
    endtask

    function void create_and_config_env();
        m_env = CpmEnv::type_id::create("m_env", this);
        m_env.m_env_cfg = CpmEnvConfig::type_id::create("m_env_cfg", this);

    endfunction

    // Function that assembel all the create and config agents
    function void create_and_config_agents(
        uvm_active_passive_enum i_input_agent_state,
        uvm_active_passive_enum o_output_agent_state,
        uvm_active_passive_enum r_reg_agent_state
        );

        // Creating && Setting the Input Agent Configuration
        m_env.m_env_cfg.m_in_agent_cfg = CpmInAgentConfig::type_id::create("m_in_agent_cfg", this);
        m_env.m_env_cfg.m_in_agent_cfg.m_is_active = i_input_agent_state;
        m_env.m_env_cfg.m_in_agent_cfg.m_vif = this.m_in_vif;

        // Creating && Setting the Output Agent Configuration
        m_env.m_env_cfg.m_out_agent_cfg = CpmOutAgentConfig::type_id::create("m_out_agent_cfg", this);
        m_env.m_env_cfg.m_out_agent_cfg.m_is_active = o_output_agent_state;
        m_env.m_env_cfg.m_out_agent_cfg.m_vif = this.m_out_vif;

        // Creating && Setting the Register Control Agent Configuration
        m_env.m_env_cfg.m_reg_agent_cfg = CpmRegAgentConfig::type_id::create("m_reg_agent_cfg", this);
        m_env.m_env_cfg.m_reg_agent_cfg.m_is_active = r_reg_agent_state;
        m_env.m_env_cfg.m_reg_agent_cfg.m_vif = this.m_reg_vif;

    endfunction
endclass