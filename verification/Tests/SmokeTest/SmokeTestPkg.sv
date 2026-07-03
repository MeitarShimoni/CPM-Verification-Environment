package SmokeTestPkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import CpmTestPkg::*;    
    import CpmEnvPkg::*;
    import CpmSequencePkg::*;

    `include "CpmSmokeVirtualSequence.sv"
    `include "SmokeTest.sv" 
endpackage