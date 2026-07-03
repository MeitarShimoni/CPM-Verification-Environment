class CpmRegSequencer extends uvm_sequencer#(CpmRegTrans);
  `uvm_component_utils(CpmRegSequencer)
  
  virtual reg_ctrl_if m_vif;
  
  function new(string name="CpmRegSequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass