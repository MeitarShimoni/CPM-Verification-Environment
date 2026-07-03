package cpm_verification_param_pkg;

    // import uvm_pkg::*;
    // `include "uvm_macros.svh"

    // Input & Output Streaming 
    localparam int PAYLOAD_WIDTH = 16;
    localparam int CTRL_WIDTH = 4;

    // Register Control Interface
    localparam int ADDR_WIDTH = 8;
    localparam int DATA_WIDTH = 32;


    // Register Abstraction Layer (RAL) Test Parameters
    localparam logic [1:0] PASS_MODE = 2'b00;
    localparam logic [1:0] XOR_MODE = 2'b01;
    localparam logic [1:0] ADD_MODE = 2'b10;
    localparam logic [1:0] ROT_MODE = 2'b11;
    localparam logic EN = 1'b1;
    localparam logic DIS = 1'b0; 


endpackage