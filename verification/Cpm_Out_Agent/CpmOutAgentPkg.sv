package CpmOutAgentPkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import CpmPacketPkg?
    import MyTransactionsPkg::*;

    `include "CpmOutDriver.sv"
    `include "CpmOutMonitor.sv"
    `include "CpmOutSequencer.sv" // NEW
    `include "CpmOutAgentConfig.sv"
    `include "CpmOutAgent.sv"

endpackage