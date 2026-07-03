//------------------------------------------------------------------------------
// FILE: CpmDriverCb.sv
// AUTHOR: Meitar Shimoni
// DATE: 15/02/2026
//
// DESCRIPTION:
//    A CallBacks Class to Pre Drive Error Injection to the Input Streaming Driver.
//------------------------------------------------------------------------------

class CpmDriverCb extends uvm_callbacks;

    // Factory Registration
    `uvm_object_utils(CpmDriverCb)

    // Constractor
    function new(string name = "CpmDriverCb");
        super.new(name);
    endfunction

    virtual task pre_send(CpmPacket pkt); 
        // As default The Pre sent doesnt do anything.
    endtask
endclass