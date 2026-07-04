
import cpm_verification_param_pkg::*;

class CpmPacket extends uvm_sequence_item;

    localparam int PAYLOAD_WIDTH = 16;
    localparam int CTRL_WIDTH = 4;

    // Register Control Interface
    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;

    // Properties
    randc logic [CTRL_WIDTH-1:0] id;      // Identifier Field
    randc logic [CTRL_WIDTH-1:0] opcode;  // Operation / Classification Field
    randc logic [PAYLOAD_WIDTH-1:0] payload; // Data Payload
    randc int delay;

    // --- שדה חדש לחישוב ה-Coverage ---
    // '1' אם המוניטור זיהה שהחבילה המתינה ל-ready
    bit was_stalled; 
    bit was_dropped;

    // Factory Registration
    `uvm_object_utils_begin(CpmPacket)
        `uvm_field_int(id,          UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(opcode,      UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(payload,     UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(delay,       UVM_ALL_ON | UVM_DEC)
        `uvm_field_int(was_stalled, UVM_ALL_ON | UVM_BIN) // הוספת השדה החדש למאקרו
        `uvm_field_int(was_dropped, UVM_ALL_ON | UVM_BIN)
    `uvm_object_utils_end

    // Constraints 
    constraint opcode_c  {opcode  inside {[0:15]};}
    constraint payload_c {payload inside {[0:65535]};}
    constraint delay_c   {delay   inside {[0:3]};}

    // Constructor
    function new(string name = "CpmPacket");
        super.new(name);
    endfunction

    function string summary();
      return $sformatf(
        { "\n====================================================================================",
          "\nCPM Packet: id = %0h | opcode  = %0h | payload = %0h | delay   = %0d | stalled = %b\n",
          "====================================================================================\n\n" },
        id, opcode, payload, delay, was_stalled
      );
    endfunction

endclass