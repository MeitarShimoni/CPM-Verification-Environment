class ResetSequence extends uvm_sequence#(CpmPacket);
    `uvm_object_utils(ResetSequence)

    // A handle to the virtual interface to toggle the reset pin
    virtual input_streaming_if m_vif;

    function new(string name = "ResetSequence");
        super.new(name);
    endfunction

    // All sequence logic MUST be inside the body task
    virtual task body();
        `uvm_info(get_type_name(), "Asserting Reset...", UVM_HIGH)

        if (m_vif == null) begin
            `uvm_fatal("VIF_NULL", "Virtual interface not set for ResetSequence")
        end

        // Drive the hardware reset signal
        m_vif.rst <= 1'b1;
        
        // Wait for a few clock cycles
        repeat(5) @(posedge m_vif.clk);
        
        m_vif.rst <= 1'b0;
        
        `uvm_info(get_type_name(), "Reset De-asserted.", UVM_HIGH)
    endtask
endclass