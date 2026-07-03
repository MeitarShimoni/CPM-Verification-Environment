class cpm_reg_adapter extends uvm_reg_adapter;
  `uvm_object_utils(cpm_reg_adapter)

  // Set this based on your DUT:
  // 1 = DUT uses word addresses (reg index), 0 = DUT uses byte addresses
  bit DUT_WORD_ADDR = 1;

  function new(string name="cpm_reg_adapter");
    super.new(name);
    supports_byte_enable = 0;
    provides_responses   = 1;
  endfunction

  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    CpmRegTrans bus_item = CpmRegTrans::type_id::create("bus_item");
    `uvm_info("ADAPT_DEBUG", $sformatf("RAL Request: %s at addr 0x%0h with data 0x%0h", 
              rw.kind.name(), rw.addr, rw.data), UVM_DEBUG)

    bus_item.write_en = (rw.kind == UVM_WRITE);
    bus_item.addr     = rw.addr;
    bus_item.wdata    = rw.data;
    return bus_item;
  endfunction

  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    CpmRegTrans t;
    if (!$cast(t, bus_item)) `uvm_fatal("ADAPT", "bus_item is not CpmRegTrans")
      
  `uvm_info("ADAPT_DEBUG", $sformatf("Updating RAL Mirror: %s addr 0x%0h, data 0x%0h", 
                t.write_en ? "WRITE" : "READ", t.addr, t.write_en ? t.wdata : t.rdata), UVM_DEBUG)

    rw.kind   = t.write_en ? UVM_WRITE : UVM_READ;
    rw.addr   = t.addr;
    rw.data   = t.write_en ? t.wdata : t.rdata;
    rw.status = UVM_IS_OK;
  endfunction
endclass
