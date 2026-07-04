package CpmSequencePkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

    import MyTransactionsPkg::*;

    import CpmInAgentPkg::*;
    import CpmOutAgentPkg::*;
    import CpmRegAgentPkg::*;

    import design_pkg_uvm::*;
    `include "CpmSequence1.sv"
    `include "CpmCoverageSequence.sv"
    `include "RegCtrlSequence.sv"
    `include "RegAccessSeq.sv"
    `include "ResetSequence.sv"
    `include "CpmOutSequence.sv"
    // `include "RegAccessSeq.sv"
    `include "CpmVirtualSequence.sv"
    `include "../Tests/StressTest/CpmStressVirtualSequence.sv"
    `include "../Tests/SmokeTest/CpmSmokeVirtualSequence.sv"

    

endpackage