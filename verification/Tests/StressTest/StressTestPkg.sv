package StressTestPkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import CpmTestPkg::*;    
    import CpmEnvPkg::*;
    import CpmSequencePkg::*;

    `include "CpmStressVirtualSequence.sv"
    `include "StressTest.sv" 
endpackage