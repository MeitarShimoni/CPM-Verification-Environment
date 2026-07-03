class CpmRegAgentConfig extends uvm_object;

    // Factory Registration
    `uvm_object_utils(CpmRegAgentConfig)

    virtual reg_ctrl_if m_vif;

    uvm_active_passive_enum m_is_active;

    function new(string name = "CpmRegAgentConfig");
        super.new(name);
    endfunction

endclass