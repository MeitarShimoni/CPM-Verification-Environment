import cpm_verification_param_pkg::*;

class CpmRegTrans extends uvm_sequence_item;

    // Properties
    rand logic write_en;
    randc logic [ADDR_WIDTH-1:0] addr;
    randc logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

    // Factory Registration
    `uvm_object_utils_begin(CpmRegTrans)
        `uvm_field_int(write_en, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(wdata, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(rdata, UVM_ALL_ON | UVM_HEX)
    `uvm_object_utils_end

    // constraints

    function new(string name = "CpmRegTrans");
        super.new(name);
    endfunction


    function string summary();
    return $sformatf(
        {"\n====================================================================================",
        "\nReg CTRL Packet: write_en = %0b | addr = 0x%02h | wdata = 0x%08h | rdata = 0x%08h\n",
        "====================================================================================\n\n" },
        write_en, addr, wdata, rdata
    );
    endfunction


endclass