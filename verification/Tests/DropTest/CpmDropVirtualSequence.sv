class CpmDropVirtualSequence extends CpmVirtualSequence;
    `uvm_object_utils(CpmDropVirtualSequence)



    virtual task body();
    uvm_status_e   status;
    uvm_reg_data_t data;

    create_sequences();


    hard_reset();

    // Configure
    m_regmodel.DROP_CFG.DROP_OPCODE.set(16'h0004);
    m_regmodel.DROP_CFG.DROP_EN.set(1'b1);
    m_regmodel.DROP_CFG.update(status, .parent(this));

    write_read_traffic(30,1,'h4);

    #30;
    // Reconfigure:    

    m_regmodel.DROP_CFG.DROP_OPCODE.set(16'h0000);
    m_regmodel.DROP_CFG.DROP_EN.set(1'b1);
    m_regmodel.DROP_CFG.update(status, .parent(this));

    write_read_traffic(30,1,'h4);





    endtask


endclass