class CpmInSequencer extends uvm_sequencer#(CpmPacket);
  `uvm_component_utils(CpmInSequencer)
  
  virtual input_streaming_if m_vif;
  
  function new(string name="CpmInSequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass