
class CpmEnvConfig extends uvm_object;

    // Factory Registration
    `uvm_object_utils(CpmEnvConfig)

    CpmInAgentConfig m_in_agent_cfg;
    CpmOutAgentConfig m_out_agent_cfg;
    CpmRegAgentConfig m_reg_agent_cfg;

    
    virtual input_streaming_if m_in_vif;
    virtual output_streaming_if m_out_vif;
    virtual reg_ctrl_if m_reg_vif;


    function new(string name = "CpmEnvConfig");
        super.new(name);
    endfunction

endclass
