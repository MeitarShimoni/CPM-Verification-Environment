// class CpmOutMonitor extends uvm_monitor;

//     `uvm_component_utils(CpmOutMonitor)

//     virtual output_streaming_if m_vif;

//     uvm_analysis_port #(CpmPacket) ap;

//     // Constractor
//     function new(string name = "CpmOutMonitor", uvm_component parent);
//         super.new(name, parent);
//     endfunction

//     // build phase
//     virtual function void build_phase(uvm_phase phase);
//         `uvm_info(get_type_name(), "inside build phase...", UVM_LOW)
//         ap = new("ap", this);
//     endfunction

//     virtual task run_phase(uvm_phase phase);
//         CpmPacket packet;
//         bit stall_happened = 0;
//         bit drop_happened = 0;
//         forever begin
//             @(m_vif.mon_cb);

//             stall_happened = 0; // Reset for next transaction
//             if (m_vif.mon_cb.out_valid && !m_vif.mon_cb.out_ready) begin
//                 `uvm_info("STALLED","STALLED HAPPEND!", UVM_LOW)
                
                
//                 stall_happened = 1;
//                 packet.was_stalled = 1'b1;
//             end
        
//             if (m_vif.mon_cb.out_valid && m_vif.mon_cb.out_ready) begin

//                 packet = CpmPacket::type_id::create("packet", this);
//                 packet.id = m_vif.mon_cb.out_id;
//                 packet.opcode = m_vif.mon_cb.out_opcode;
//                 packet.payload = m_vif.mon_cb.out_payload;

//                 // packet.was_stalled = stall_happened;

//                 `uvm_info("MONITOR", $sformatf("Sampled Packet: %s", packet.convert2string()), UVM_MEDIUM)
//                 ap.write(packet);
//             end
//         end
//     endtask



// endclass


class CpmOutMonitor extends uvm_monitor;

    `uvm_component_utils(CpmOutMonitor)

    virtual output_streaming_if m_vif;
    uvm_analysis_port #(CpmPacket) ap;

    // Constructor
    function new(string name = "CpmOutMonitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build Phase
    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "inside build phase...", UVM_LOW)
        // if (!uvm_config_db#(virtual output_streaming_if)::get(this, "", "m_vif", m_vif)) begin
        //     `uvm_fatal("MONITOR", "Could not get virtual interface!")
        // end
        ap = new("ap", this);
    endfunction

    // Run Phase
    virtual task run_phase(uvm_phase phase);
        CpmPacket packet;
        bit stall_happened = 0; // משתנה מקומי למעקב אחרי Backpressure

        forever begin
            @(m_vif.mon_cb);

            // 1. זיהוי מצב של Backpressure (עיכוב)
            if (m_vif.mon_cb.out_valid && !m_vif.mon_cb.out_ready) begin
                stall_happened = 1;
            end
        
            // 2. זיהוי לחיצת יד מוצלחת (Handshake)
            if (m_vif.mon_cb.out_valid && m_vif.mon_cb.out_ready) begin

                packet = CpmPacket::type_id::create("packet", this);
                packet.id      = m_vif.mon_cb.out_id;
                packet.opcode  = m_vif.mon_cb.out_opcode;
                packet.payload = m_vif.mon_cb.out_payload;

                // עדכון המטא-דאטה שנאסף
                packet.was_stalled = stall_happened;
                stall_happened = 0; // איפוס לקראת הפקט הבא כדי שלא "ידביק" פקטים אחרים

                // שימוש ב-summary במקום convert2string לפי המחלקה שהגדרת
                `uvm_info("MONITOR", $sformatf("Sampled Packet: %s", packet.summary()), UVM_LOW)
                ap.write(packet);
            end
        end
    endtask

endclass