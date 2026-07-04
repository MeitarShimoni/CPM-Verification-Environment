class CpmStressVirtualSequence extends CpmVirtualSequence;
    `uvm_object_utils(CpmStressVirtualSequence)



    virtual task body();
        uvm_status_e   status;
        uvm_reg_data_t data;

        create_sequences();

        // 1. Reset
        if (m_in_seqr != null) begin
            rst_seq.m_vif = m_in_seqr.m_vif;
            rst_seq.start(m_in_seqr);
        end

        #50ns; 

        // 2. Configuration 
        `uvm_info("VSEQ", "Configuring DUT Mode and Params...", UVM_LOW)
        
        m_regmodel.MODE.write(status, 2'b01, .parent(this));   // XOR
        m_regmodel.PARAMS.MASK.write(status, 16'h00FF, .parent(this));

        // 3. Enabling 
        `uvm_info("VSEQ", "Step 2: Enabling CPM (Hard Write)", UVM_LOW)
        m_regmodel.CTRL.write(status, 32'h1, .parent(this)); 
        
        m_regmodel.CTRL.read(status, data, .parent(this));
        `uvm_info("VSEQ", $sformatf("Readback CTRL: 0x%0h", data), UVM_LOW)

        #100ns; 

        // 4. Parallel Traffic
        `uvm_info("VSEQ", "Starting Parallel Traffic Flow", UVM_LOW)
        
        this.output_delay = 2;

        fork
            begin
                m_seq.num_packets = 20;
                m_seq.start(m_in_seqr, this);
            end
            begin
                #200ns; // "Stall" 
                m_out_seq.num_packets = 20;
                m_out_seq.out_delay   = this.output_delay;
                m_out_seq.start(m_out_seqr, this);
            end
        join
        #100;

        
        // 5. Log DUT counters (verification only; we do not assume design invariant IN==OUT+DROP).
        check_invariants();
    endtask

endclass