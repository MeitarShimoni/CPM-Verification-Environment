package CpmRegAgentPkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import CpmPacketPkg?
    import MyTransactionsPkg::*;

    `include "CpmRegSequencer.sv"
    `include "CpmRegDriver.sv"
    `include "CpmRegMonitor.sv"
    `include "CpmRegAgentConfig.sv"
    `include "CpmRegAgent.sv"

endpackage