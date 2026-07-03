class StressSequence extends uvm_sequence #(CpmPacket);

    // Factory Registration
    `uvm_object_utils(CpmPacket)

    // Constractor
    function new(string name = "StressSequence")
        super.new(name);
    endfunction

    virtual task body();
        CpmPacket trans
        repeat(100) begin 
            trans = CpmPacket::type_id::create("trans");
            start_item(trans);
            // Rndomize the StreamInPacket
            if (!trans.randomize()) 
                `uvm_error(get_type_name(), "inline randomization error")
           
            finish_item(trans);
        end
    endtask

endclass