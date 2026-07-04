

package CpmEnvPkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Imports
  import CpmInAgentPkg::*;
  import CpmOutAgentPkg::*;
  import CpmRegAgentPkg::*;     
  import MyTransactionsPkg::*;
  import design_pkg_uvm::*;     


  `include "CpmEnvConfig.sv"
  `include "CoverageCollector.sv"
  `include "../RAL/cpm_reg_adapter.sv"

  `include "RefModel.sv"
  `include "CpmScoreboard.sv"

  `include "CpmEnv.sv"
endpackage