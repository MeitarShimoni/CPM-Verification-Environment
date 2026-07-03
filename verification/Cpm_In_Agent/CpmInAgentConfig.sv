//------------------------------------------------------------------------------
// FILE: CpmInAgentConfig.sv
// AUTHOR: Meitar Shimoni
// DATE: 30/01/2026
//
// DESCRIPTION:
//    Configure the agent for Input Streaming.
//------------------------------------------------------------------------------

class CpmInAgentConfig extends uvm_object;

    // Factory Registration
    `uvm_object_utils(CpmInAgentConfig)

    uvm_active_passive_enum m_is_active;

    virtual input_streaming_if m_vif;

    function new(string name = "CpmInAgentConfig");
        super.new(name);
    endfunction

endclass