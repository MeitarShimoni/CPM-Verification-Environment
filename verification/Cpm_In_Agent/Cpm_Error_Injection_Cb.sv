class Cpm_Error_Injection_Cb extends CpmDriverCb;

    // Factory Registration
    `uvm_object_utils(Cpm_Error_Injection_Cb)

    // The Implementation of the pre_sent Task for Error Injection
    virtual task pre_send(CpmPacket pkt);
        `uvm_info("ERROR INJECTION CALLBACKS", "Callbacks Active: Modifying opcode!", UVM_LOW)
        pkt.opcode = 4'hF;
    endtask


endclass