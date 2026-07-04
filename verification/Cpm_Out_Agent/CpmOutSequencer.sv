class CpmOutSequencer extends uvm_sequencer#(CpmOutTransaction);
  `uvm_component_utils(CpmOutSequencer)
  
  virtual output_streaming_if m_vif; // FIXED!!!!!!!!!!!!!!!!!!!!!!!!
  
  function new(string name="CpmOutSequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
  
endclass