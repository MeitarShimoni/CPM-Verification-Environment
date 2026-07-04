package CpmInAgentPkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // import CpmPacketPkg?
    import MyTransactionsPkg::*;

    // typedef class cpm_reg_map;

    `include "CpmInDriver.sv"
    // `include "CpmDriverCb.sv"
    `include "CpmInMonitor.sv"
    `include "CpmInSequencer.sv"
    `include "CpmInAgentConfig.sv"
    `include "CpmInAgent.sv"

endpackage