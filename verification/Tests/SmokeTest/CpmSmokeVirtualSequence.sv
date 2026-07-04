class CpmSmokeVirtualSequence extends CpmVirtualSequence;
    `uvm_object_utils(CpmSmokeVirtualSequence)

    // for Coverage Enclosure we need 15 packets at random cyclic
    int num_packets_to_send = 15;

virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t data;

    create_sequences();

    hard_reset();
    #50ns;

     
    enable_cpm(); // Enable and Read CPM
    #20;
    
    // drop_test(20);
    // =================== PASS TEST ======================
    pass_test(10);
    
    // write_read_traffic_stress(10);    
    #20;
    
    rot_test(10);
    #20;

    // // =================== XOR TEST ======================
    xor_test(16'h1234, 10);
    
    #20;
    // // =================== ADD TEST ======================
    add_test(16'h0002, 10);
    #20;

    check_invariants();
  endtask
  


endclass