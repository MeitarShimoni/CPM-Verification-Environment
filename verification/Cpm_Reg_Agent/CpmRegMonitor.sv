class CpmRegMonitor extends uvm_monitor;
    
    // Factory Registration
    `uvm_component_utils(CpmRegMonitor)

    // Class Properties
    virtual reg_ctrl_if m_vif;

    // Analysis Ports
    uvm_analysis_port#(CpmRegTrans) ap;
    
    // Constractor
    function new(string name = "CpmRegMonitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        ap = new("ap", this);
    endfunction

    // Run Phase
    virtual task run_phase(uvm_phase phase);
        CpmRegTrans packet;

        forever begin
            @(m_vif.mon_cb);
            if (m_vif.mon_cb.req && m_vif.mon_cb.gnt) begin

                packet = CpmRegTrans::type_id::create("packet", this);
                packet.write_en = m_vif.mon_cb.write_en;
                packet.addr = m_vif.mon_cb.addr;
                packet.wdata = m_vif.mon_cb.wdata;
                packet.rdata = m_vif.mon_cb.rdata;

                ap.write(packet);
                `uvm_info("REG_MONITOR:", packet.summary(), UVM_HIGH)
            end
        end
    endtask
endclass