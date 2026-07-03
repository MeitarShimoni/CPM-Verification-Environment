class CpmSequence1 extends uvm_sequence#(CpmPacket);

    `uvm_object_utils(CpmSequence1)

    // Configuration Knobs for Virtual Sequence control
    rand int num_packets = 10;
    rand bit use_forced_opcode = 0;   // When 1, we ignore random opcodes
    rand logic [3:0] forced_opcode;  // The specific opcode we want to send
    rand bit use_delay = 0;
    rand int delay_f = 0;
    function new(string name = "CpmSequence1");
        super.new(name);
    endfunction

    virtual task body();
        CpmPacket trans;
        trans = CpmPacket::type_id::create("trans");

        repeat(num_packets) begin
            start_item(trans);

            // Randomize with a conditional constraint to "force" the opcode
            if (!trans.randomize() with { 
                if (use_forced_opcode) opcode == forced_opcode; 
                if(use_delay) delay == delay_f;
            }) begin
                `uvm_error(get_type_name(), "Randomization failed")
            end

            `uvm_info("CpmSequence1", $sformatf("Generated packet: %s", trans.summary()), UVM_MEDIUM)
            finish_item(trans);
        end
    endtask

endclass