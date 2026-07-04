
package CpmTestPkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import cpm_verification_param_pkg::*;
  import MyTransactionsPkg::*;

  import CpmInAgentPkg::*;
  import CpmOutAgentPkg::*;
  import CpmRegAgentPkg::*;

  import CpmEnvPkg::*;
  import CpmSequencePkg::*;

  // `include "Cpm_In_Agent/Cpm_Error_Injection_Cb"

  `include "CpmBaseTest/CpmBaseTest.sv"

endpackage
