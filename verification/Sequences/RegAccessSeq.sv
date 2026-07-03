class RegAccessSeq extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(RegAccessSeq)
    
    cpm_reg_map m_regmodel;
    
    // Knobs for configuration
    logic [1:0] mode_to_set = 2'b00;
    logic [31:0] ctrl_val   = 32'h0;
    bit          do_enable  = 0; 
    bit          do_mode    = 0;

    virtual task body();
        uvm_status_e status;

        // 1. Handle Enable (CTRL Register)
        if (do_enable) begin
            `uvm_info("REG_SEQ", "Enabling CPM via CTRL", UVM_LOW)
            m_regmodel.CTRL.ENABLE.set(1'b1);
            m_regmodel.CTRL.update(status, .parent(this));
        end

        // 2. Handle Mode/Params
        if (do_mode) begin
            `uvm_info("REG_SEQ", $sformatf("Setting Mode: %0b", mode_to_set), UVM_LOW)
            m_regmodel.MODE.MODE_reg.set(mode_to_set);
            m_regmodel.MODE.update(status, .parent(this));
        end
    endtask
endclass