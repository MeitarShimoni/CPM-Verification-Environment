class CpmCoverageSequence extends CpmSequence1; 
    `uvm_object_utils(CpmCoverageSequence)

    function new(string name = "CpmCoverageSequence");
        super.new(name);
    endfunction

    // constraint rare_traffic_c {
    //     mode_val inside {2, 3};      
    //     opcode_val inside {[4'hA:4'hF]}; 
    // }
endclass