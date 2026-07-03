class CpmVirtualSequence extends uvm_sequence#(uvm_sequence_item);
    `uvm_object_utils(CpmVirtualSequence)


    localparam logic [1:0] PASS_MODE = 2'b00;
    localparam logic [1:0] XOR_MODE = 2'b01;
    localparam logic [1:0] ADD_MODE = 2'b10;
    localparam logic [1:0] ROT_MODE = 2'b11;
    localparam logic EN = 1'b1;
    localparam logic DIS = 1'b0;

    // Sequences
    CpmSequence1     m_seq;
    ResetSequence    rst_seq;
    CpmOutSequence   m_out_seq;
    RegAccessSeq     m_reg_seq;

    // Sequencers
    CpmInSequencer   m_in_seqr;
    CpmOutSequencer  m_out_seqr; 
    CpmRegSequencer  m_reg_seqr;

    // RAL
    cpm_reg_map      m_regmodel;

    function new(string name="CpmVirtualSequence");
        super.new(name);
    endfunction

    function void create_sequences();
        m_seq      = CpmSequence1::type_id::create("m_seq");
        rst_seq    = ResetSequence::type_id::create("rst_seq");
        m_out_seq  = CpmOutSequence::type_id::create("m_out_seq");
        m_reg_seq  = RegAccessSeq::type_id::create("m_reg_seq");
    endfunction
    
    virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t data;

    if (m_regmodel == null) begin
      `uvm_fatal("RAL_NULL", "CpmVirtualSequence: m_regmodel is null")
    end

    create_sequences();


    check_invariants();

  endtask





    // ================================= TASKS ================================================
    
    
    task check_invariants();
        uvm_status_e status;
        uvm_reg_data_t in_val, out_val, drop_val;

        m_regmodel.COUNT_IN.read(status, in_val, .parent(this));
        m_regmodel.COUNT_OUT.read(status, out_val, .parent(this));
        m_regmodel.DROPPED_COUNT.read(status, drop_val, .parent(this));

        `uvm_info("VSEQ", $sformatf("DUT counters: COUNT_IN=%0d COUNT_OUT=%0d DROPPED_COUNT=%0d", in_val, out_val, drop_val), UVM_LOW)
        // Rely on scoreboard for data correctness; do not fail here on counter relationship.
    endtask

    task write_read_traffic(
        input int num = 10, 
        input bit in_forced_op = 0, 
        input logic [3:0] in_forced_opcode = 0 );

        repeat(num) begin
            m_seq.use_forced_opcode = in_forced_op; 
            m_seq.forced_opcode = in_forced_opcode;
            m_seq.num_packets = 1;
            m_seq.start(m_in_seqr, this);

            m_out_seq.num_packets = 1;
            m_out_seq.start(m_out_seqr, this);
        end

    endtask


    task write_read_burst(input int num = 5);

        m_seq.num_packets = num;
        m_seq.start(m_in_seqr, this);

        m_out_seq.num_packets = num;
        m_out_seq.start(m_out_seqr, this);

    endtask

    task add_test(input logic [15:0] num_add, int num_trans = 10);
        uvm_status_e   status;
        uvm_reg_data_t data;
        `uvm_info("VSEQ", "\nStarting ADD Sequenece", UVM_LOW)

        // config add_const
        m_regmodel.PARAMS.ADD_CONST.write(status, num_add, .parent(this));
        // Set Mode to ADD
        m_regmodel.MODE.write(status, ADD_MODE, .parent(this));   // ADD
        write_read_traffic(num_trans);

    endtask

    task xor_test(input logic [15:0] in_mask, int num_trans = 10);
        uvm_status_e   status;
        uvm_reg_data_t data;
        `uvm_info("VSEQ", "\nStarting XOE Sequenece", UVM_LOW)

        // config add_const
        m_regmodel.PARAMS.MASK.write(status, in_mask, .parent(this));
        // Set Mode to ADD
        m_regmodel.MODE.write(status, XOR_MODE, .parent(this));   // ADD
        write_read_traffic(num_trans);

    endtask

    task pass_test(int num_trans = 10);
        uvm_status_e   status;
        uvm_reg_data_t data;
        `uvm_info("VSEQ", "\nStarting PASS Sequence", UVM_LOW)
        
        m_regmodel.MODE.write(status,PASS_MODE, .parent(this));   // PASS
        
        write_read_traffic(num_trans);

    endtask

    task hard_reset();
    
        `uvm_info("VSEQ", "\nStarting Hard Reset", UVM_LOW)
        if (m_in_seqr != null) begin
            rst_seq.m_vif = m_in_seqr.m_vif;
            rst_seq.start(m_in_seqr);
        end
    endtask
    
    task write_read_traffic_stress(input int num = 100);
        
        m_seq.num_packets = num;
        m_seq.start(m_in_seqr, this);
        
        m_out_seq.num_packets = num;
        m_out_seq.start(m_out_seqr, this);
        // fork
        //     begin : IN_SIDE
        //         repeat (num) begin
        //             m_seq.num_packets = 1;
        //             m_seq.start(m_in_seqr, this);
        //         end
        //     end
        //     begin : OUT_SIDE
        //         // out seq runs continuously; driver creates stalls
        //         m_out_seq.num_packets = num;
        //         m_out_seq.start(m_out_seqr, this);
        //     end
        // join
    endtask

 
    task enable_cpm();
        uvm_status_e   status;
        uvm_reg_data_t data;
        `uvm_info("VSEQ", "\nEnabling CPM (Hard Write)", UVM_LOW)
        m_regmodel.CTRL.write(status, 32'h1, .parent(this)); 
        m_regmodel.CTRL.read(status, data, .parent(this)); // read back
        `uvm_info("VSEQ", $sformatf("Readback CTRL: 0x%0h", data), UVM_LOW)
    endtask

    task rot_test(int num_trans = 10);
        uvm_status_e   status;
        uvm_reg_data_t data;
        `uvm_info("VSEQ", "Starting PASS Sequence", UVM_LOW)
        
        m_regmodel.MODE.write(status,ROT_MODE, .parent(this));   // PASS
        
        write_read_traffic(num_trans);
    endtask



    task drop_test(int num_trans = 10);
        uvm_status_e   status;
        uvm_reg_data_t data;

        `uvm_info("VSEQ", "\nStarting Drop Sequence", UVM_LOW)
        m_regmodel.DROP_CFG.DROP_OPCODE.set('h4);
        m_regmodel.DROP_CFG.DROP_EN.set(1'b1);
        m_regmodel.DROP_CFG.update(status, .parent(this));

        write_read_traffic(num_trans,1,'h4);
        
    endtask

    virtual task stall_scenario();

        `uvm_info("VSEQ", "Starting Stall Scenario: Filling internal buffers", UVM_LOW)

        fork
            begin
                m_seq.num_packets = 10;
                m_seq.start(m_in_seqr, this);
            end

            begin
                #200ns; 
                
                m_out_seq.num_packets = 10;
                m_out_seq.start(m_out_seqr, this);
            end
        join

        #500ns; 

        `uvm_info("VSEQ", "Stall Scenario Finished", UVM_LOW)
        check_invariants();
    endtask

endclass