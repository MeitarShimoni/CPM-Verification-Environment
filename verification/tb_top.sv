
module tb_top;

  logic clk;


  // interfaces
  input_streaming_if  m_in_vif(.clk(clk));
  output_streaming_if m_out_vif(.clk(clk));
  reg_ctrl_if         m_reg_vif(.clk(clk));

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import cpm_verification_param_pkg::*;
  import MyTransactionsPkg::*;
  import CpmInAgentPkg::*;
  import CpmOutAgentPkg::*;
  import CpmRegAgentPkg::*;
  import CpmEnvPkg::*;
  import CpmSequencePkg::*;
  import CpmTestPkg::*;
  
  import SmokeTestPkg::*;  
  import StressTestPkg::*;  
  import DropTestPkg::*;  
  // Add DropTestPkg here when ready

  // clock
  initial clk = 0;
  always #5 clk = ~clk;


  cpm dut(
    .clk(m_in_vif.clk),
    .rst(m_in_vif.rst),
    .in_valid(m_in_vif.in_valid),
    .in_ready(m_in_vif.in_ready),
    .in_id(m_in_vif.in_id),
    .in_opcode(m_in_vif.in_opcode),
    .in_payload(m_in_vif.in_payload),
    .out_valid(m_out_vif.out_valid),
    .out_ready(m_out_vif.out_ready),
    .out_id(m_out_vif.out_id),
    .out_opcode(m_out_vif.out_opcode),
    .out_payload(m_out_vif.out_payload),
    .req(m_reg_vif.req),
    .gnt(m_reg_vif.gnt),
    .write_en(m_reg_vif.write_en),
    .addr(m_reg_vif.addr),
    .wdata(m_reg_vif.wdata),
    .rdata(m_reg_vif.rdata)
  );


  initial begin
    
    uvm_config_db#(virtual input_streaming_if )::set(null, "", "m_in_vif",  m_in_vif);
    uvm_config_db#(virtual output_streaming_if)::set(null, "", "m_out_vif", m_out_vif);
    uvm_config_db#(virtual reg_ctrl_if        )::set(null, "", "m_reg_vif", m_reg_vif);

    // uvm_config_db#(virtual input_streaming_if)::set(null, "*m_in_agent*", "m_vif", m_in_vif);
    // uvm_config_db#(virtual output_streaming_if)::set(null, "*m_out_agent*", "m_vif", m_out_vif);
    // uvm_config_db#(virtual reg_ctrl_if)::set(null, "*m_reg_agent*", "m_vif", m_reg_vif);
    
    // reset_dut();
    $display("[%0t] TB_TOP: starting run_test(CpmTest)", $time);
    run_test();
    
  end


  task reset_dut();
    m_in_vif.rst = 0;
    #10;
    m_in_vif.rst = 1;
    #10;
    m_in_vif.rst = 0;
  endtask


endmodule
