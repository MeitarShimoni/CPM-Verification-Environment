
import cpm_verification_param_pkg::*;

interface output_streaming_if(input logic clk);

    // Input & Output Ports 
    logic rst;
    logic out_valid;
    logic out_ready;
    logic [CTRL_WIDTH-1:0] out_id; 
    logic [CTRL_WIDTH-1:0] out_opcode;
    logic [PAYLOAD_WIDTH-1:0] out_payload;

    // Driver Clocking Block
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        input out_valid, out_id, out_opcode, out_payload;
        output out_ready;
    endclocking

    // Monitor Clocking Block
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input out_valid, out_ready, out_id, out_opcode, out_payload;
    endclocking

    // Modports
    modport drv (clocking drv_cb, input clk, input rst);
    modport mon (clocking mon_cb, input clk, input rst);


    // SystemVerilog Assertions
    property output_stable;
        @(posedge clk) disable iff (rst)
        (out_valid && !out_ready) |=> $stable({out_id, out_opcode, out_payload});
    endproperty

    assert_output_stable: assert property(output_stable)
        else $error("Protocol Violation: Output signal changed while out_ready is low!");

endinterface