class CpmOutAgentConfig extends uvm_object;

    // Factory Registration
    `uvm_object_utils(CpmOutAgentConfig)

    uvm_active_passive_enum m_is_active;
    
    virtual output_streaming_if m_vif;
    
    function new(string name = "CpmOutAgentConfig");
        super.new(name);
    endfunction

endclass