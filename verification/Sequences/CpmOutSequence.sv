// class CpmOutSequence

class CpmOutSequence extends uvm_sequence#(CpmOutTransaction);

    `uvm_object_utils(CpmOutSequence)

    rand int num_packets = 10;
    rand int out_delay = 0; 

    function new(string name = "CpmOutSequence");
        super.new(name);
    endfunction

    virtual task body();
        CpmOutTransaction trans;
        repeat(num_packets) begin
            trans = CpmOutTransaction::type_id::create("trans");
            start_item(trans);
            
            if (!trans.randomize() with { delay == out_delay; }) `uvm_error(get_type_name(), "Randomization failed")
            finish_item(trans);
        end
    endtask

endclass


// virtual task body();
//         CpmOutTransaction trans;
//         repeat(num_packets) begin
//             trans = CpmOutTransaction::type_id::create("trans");
//             start_item(trans);
            
//             // Inline constraint guarantees delay is exactly 0
//             if (!trans.randomize() with { delay == 0; }) begin
//                 `uvm_error(get_type_name(), "Randomization failed")
//             end
            
//             finish_item(trans);
//         end
//     endtask