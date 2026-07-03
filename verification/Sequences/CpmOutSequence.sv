// class CpmOutSequence

class CpmOutSequence extends uvm_sequence#(CpmOutTransaction);

    `uvm_object_utils(CpmOutSequence)

    rand int num_packets = 10;
 

    function new(string name = "CpmOutSequence");
        super.new(name);
    endfunction

    virtual task body();
        CpmOutTransaction trans;
        repeat(num_packets) begin
            trans = CpmOutTransaction::type_id::create("trans");
            start_item(trans);
            if (!trans.randomize()) `uvm_error(get_type_name(), "Randomization failed")
            finish_item(trans);
        end
    endtask

endclass
