

class CpmRegDriver extends uvm_driver #(CpmRegTrans);

  `uvm_component_utils(CpmRegDriver)

  virtual reg_ctrl_if m_vif;

  // Tune if needed
  localparam int unsigned GNT_TIMEOUT_CYCLES = 2000;

  function new(string name="CpmRegDriver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build Phase
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "inside build phase...", UVM_LOW)

    if (!uvm_config_db#(virtual reg_ctrl_if)::get(this, "", "m_vif", m_vif)) begin
      `uvm_fatal("REG_DRV", "Could not get reg_ctrl_if (m_vif) from config_db")
    end
  endfunction


  virtual task run_phase(uvm_phase phase);
    CpmRegTrans req;
    CpmRegTrans rsp;

    // Drive defaults (idle)
    m_vif.drv_cb.req      <= 1'b0;
    m_vif.drv_cb.write_en <= 1'b0;
    m_vif.drv_cb.addr     <= '0;
    m_vif.drv_cb.wdata    <= '0;

    forever begin
      seq_item_port.get_next_item(req);
      `uvm_info("REG_PKT", req.summary(), UVM_HIGH)

      drive_transaction(req);

      // Create and send a response (good for RAL / sequences that expect it)
      rsp = CpmRegTrans::type_id::create("rsp", this);
      rsp.copy(req);
      rsp.set_id_info(req);
      rsp.rdata = req.rdata;

      seq_item_port.put_response(rsp);
      seq_item_port.item_done();
    end
  endtask


  local task drive_transaction(ref CpmRegTrans t);
    int unsigned cycles;
    bit accepted;

    // Align to the clocking block
    @(m_vif.drv_cb);

    // Drive request and fields
    m_vif.drv_cb.addr     <= t.addr;
    m_vif.drv_cb.write_en <= t.write_en;
    m_vif.drv_cb.wdata    <= (t.write_en) ? t.wdata : '0;
    m_vif.drv_cb.req      <= 1'b1;

    // Wait for accept: req && gnt (not only gnt)
    cycles   = 0;
    accepted = 0;

    while (!accepted) begin
      @(m_vif.drv_cb);

      accepted = (m_vif.drv_cb.req === 1'b1) && (m_vif.drv_cb.gnt === 1'b1);

      cycles++;
      if (cycles >= GNT_TIMEOUT_CYCLES) begin
        `uvm_error("REG_DRV_TO",
          $sformatf("Timeout waiting for accept (req&&gnt). addr=0x%0h write_en=%0b wdata=0x%0h req=%b gnt=%b",t.addr, t.write_en, t.wdata,
          m_vif.drv_cb.req, m_vif.drv_cb.gnt))

        // Release the bus cleanly
        m_vif.drv_cb.req      <= 1'b0;
        m_vif.drv_cb.write_en <= 1'b0;
        m_vif.drv_cb.addr     <= '0;
        m_vif.drv_cb.wdata    <= '0;

        // Make read data known in failure case
        if (!t.write_en) t.rdata = '0;
        return;
      end
    end

    // Accepted -> drop req
    m_vif.drv_cb.req <= 1'b0;

    // READ: sample rdata next cycle after accept (stable point)
    if (!t.write_en) begin
      @(m_vif.drv_cb);
      t.rdata = m_vif.drv_cb.rdata;
    end

    // Tidy idle
    m_vif.drv_cb.write_en <= 1'b0;
    m_vif.drv_cb.addr     <= '0;
    m_vif.drv_cb.wdata    <= '0;
  endtask

endclass
