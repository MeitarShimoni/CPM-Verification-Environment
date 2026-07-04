// class CoverageCollector extends uvm_subscriber #(CpmPacket);
//     `uvm_component_utils(CoverageCollector)
    
//     CpmPacket local_packet;
//     bit [1:0] current_mode; 
    
//     cpm_reg_map m_regmodel;

//     covergroup StreamCoverage;
//         // ... option.per_instance = 1 ...

//         // 1. ADDED PASS MODE (2'b00)
//         cp_mode: coverpoint current_mode {
//             bins modes[] = {2'b00, 2'b01, 2'b10, 2'b11}; 
//         }

//         cp_opcode: coverpoint local_packet.opcode {
//             bins all_opcodes[] = {[0:15]};
//         }

//         cross_mode_opcode: cross cp_mode, cp_opcode;

//         // 2. ADDED DROP COVERAGE
//         // You need a flag in your CpmPacket (from the monitor) that indicates a drop
//         cp_drop: coverpoint local_packet.was_dropped {
//             bins dropped = {1};
//             option.comment = "Must hit at least once for closure";
//         }

//         cp_stall: coverpoint local_packet.was_stalled {
//             bins stalled = {1}; 
//         }
//     endgroup

//     function new(string name = "CoverageCollector", uvm_component parent);
//         super.new(name, parent);
//         StreamCoverage = new();
//     endfunction

//     virtual function void write(CpmPacket t);
//         this.local_packet = t;

//         if (m_regmodel != null) begin
//             current_mode = m_regmodel.MODE.MODE_reg.get();
//         end

//         `uvm_info("COV_SAMPLE", $sformatf("Sampling: ID=%0h, Opcode=%0h, Mode=%0b, Stall=%0b", 
//                   t.id, t.opcode, current_mode, t.was_stalled), UVM_HIGH)

//         this.StreamCoverage.sample();
//     endfunction

//     virtual function void report_phase(uvm_phase phase);
//         real total_cov = StreamCoverage.get_inst_coverage();
//         `uvm_info("COV_FINAL", $sformatf("Final Coverage for %s: %0.2f%%", get_name(), total_cov), UVM_DEBUG)
//     endfunction
// endclass


// 1. הגדרת פקודות המאקרו מחוץ למחלקה כדי ליצור סיומות מותאמות אישית ל-ports
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class CoverageCollector extends uvm_component;
    `uvm_component_utils(CoverageCollector)
    
    // 2. הגדרת שני ערוצי קליטה נפרדים
    uvm_analysis_imp_in  #(CpmPacket, CoverageCollector) analysis_export_in;
    uvm_analysis_imp_out #(CpmPacket, CoverageCollector) analysis_export_out;

    bit [1:0] current_mode; 
    cpm_reg_map m_regmodel;

    // 3. הגדרת ה-Covergroup עם פונקציית sample מפורשת
    covergroup StreamCoverage with function sample(CpmPacket pkt, bit [1:0] mode);
        option.per_instance = 1;

        cp_mode: coverpoint mode {
            bins modes[] = {2'b00, 2'b01, 2'b10, 2'b11}; 
        }

        cp_opcode: coverpoint pkt.opcode {
            bins all_opcodes[] = {[0:15]};
        }

        cross_mode_opcode: cross cp_mode, cp_opcode;

        cp_drop: coverpoint pkt.was_dropped {
            bins dropped     = {1};
            bins not_dropped = {0};
            option.comment = "Must hit at least once for closure";
        }

        cp_stall: coverpoint pkt.was_stalled {
            bins stalled     = {1}; 
            bins not_stalled = {0}; 
        }
    endgroup

    // Constructor
    function new(string name = "CoverageCollector", uvm_component parent);
        super.new(name, parent);
        StreamCoverage = new();
        
        // יצירת מופעים ל-Ports
        analysis_export_in  = new("analysis_export_in", this);
        analysis_export_out = new("analysis_export_out", this);
    endfunction

    // 4. פונקציית write עבור ה-Input Agent
    virtual function void write_in(CpmPacket t);
        if (m_regmodel != null) begin
            current_mode = m_regmodel.MODE.MODE_reg.get();
        end

        `uvm_info("COV_IN", $sformatf("IN Sample: ID=%0h, Opcode=%0h, Mode=%0b, Drop=%0b", 
                  t.id, t.opcode, current_mode, t.was_dropped), UVM_HIGH)

        this.StreamCoverage.sample(t, current_mode);
    endfunction

    // 5. פונקציית write עבור ה-Output Agent
    virtual function void write_out(CpmPacket t);
        if (m_regmodel != null) begin
            current_mode = m_regmodel.MODE.MODE_reg.get();
        end

        `uvm_info("COV_OUT", $sformatf("OUT Sample: ID=%0h, Opcode=%0h, Mode=%0b, Stall=%0b", 
                  t.id, t.opcode, current_mode, t.was_stalled), UVM_HIGH)

        this.StreamCoverage.sample(t, current_mode);
    endfunction

    // Report Phase להדפסת האחוז הסופי
    virtual function void report_phase(uvm_phase phase);
        real total_cov = StreamCoverage.get_inst_coverage();
        `uvm_info("COV_FINAL", $sformatf("Final Coverage for %s: %0.2f%%", get_name(), total_cov), UVM_NONE)
    endfunction

endclass