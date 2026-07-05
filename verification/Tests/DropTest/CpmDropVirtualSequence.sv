class CpmDropVirtualSequence extends CpmVirtualSequence;
    `uvm_object_utils(CpmDropVirtualSequence)



    virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t data;

    create_sequences();


    hard_reset();

    enable_cpm(); // Enable and Read CPM
    #20;


    // for (int i = 0; i < 9; i++) begin
    //     drop_test(10, i); 
    //     #10;
    // end
    
    drop_test(12, 4); 
    #10;
    drop_test(12, 9); 
    

    endtask


endclass