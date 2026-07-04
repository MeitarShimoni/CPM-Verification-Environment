

interface input_streaming_if(input logic clk);
    
import cpm_verification_param_pkg::*;
    // Input & Output Ports 
    logic rst;
    logic in_valid;
    logic in_ready;
    logic [CTRL_WIDTH-1:0] in_id; 
    logic [CTRL_WIDTH-1:0] in_opcode;
    logic [PAYLOAD_WIDTH-1:0] in_payload;

    // Driver Clocking Block
    clocking drv_cb @(posedge clk);
        default input #1ns output #0ns;
        output in_valid, in_id, in_opcode, in_payload;
        input in_ready;
    endclocking

    // Monitor Clocking Block
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input in_valid, in_ready, in_id, in_opcode, in_payload;
    endclocking

    // Modports
    modport drv (clocking drv_cb, input clk, input rst);
    modport mon (clocking mon_cb, input clk, input rst);


    // SystemVerilog Assertions
    property input_stable;
        @(posedge clk) disable iff (rst)
        (in_valid && !in_ready) |=> $stable({in_id, in_opcode, in_payload});
    endproperty

    assert_input_stable: assert property(input_stable)
        else $error("Protocol Violation: Input signal changed while in_ready is low!");


endinterface 