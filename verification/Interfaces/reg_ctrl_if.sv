
import cpm_verification_param_pkg::*;

interface reg_ctrl_if(input logic clk);

    // Input & Output Ports 
    logic rst;
    logic req;
    logic gnt;
    logic write_en;
    logic [ADDR_WIDTH-1:0] addr;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

    // Driver Clocking Block
    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output req, write_en, addr, wdata;
        input gnt, rdata;
    endclocking

    // Monitor Clocking Block
    clocking mon_cb @(posedge clk);
        default input #1ns output #1ns;
        input req, write_en, gnt, addr, wdata, rdata;
    endclocking

    // Modports
    modport drv (clocking drv_cb, input clk, input rst);
    modport mon (clocking mon_cb, input clk, input rst);


    // SystemVerilog Assertions
    property gnt_assert_with_req;
        @(posedge clk) disable iff (rst)
        req |-> gnt;
    endproperty

    assert_reg_gnt: assert property(gnt_assert_with_req)
        else $error("Protocol Violation: gnt must be asserted immediately when req is high!"); 

endinterface