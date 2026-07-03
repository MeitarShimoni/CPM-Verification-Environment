class CoverageCollector extends uvm_subscriber #(CpmPacket);
    `uvm_component_utils(CoverageCollector)
    
    CpmPacket local_packet;
    bit [1:0] current_mode; 
    
    cpm_reg_map m_regmodel;

    covergroup StreamCoverage;
        // ... option.per_instance = 1 ...

        // 1. ADDED PASS MODE (2'b00)
        cp_mode: coverpoint current_mode {
            bins modes[] = {2'b00, 2'b01, 2'b10, 2'b11}; 
        }

        cp_opcode: coverpoint local_packet.opcode {
            bins all_opcodes[] = {[0:15]};
        }

        cross_mode_opcode: cross cp_mode, cp_opcode;

        // 2. ADDED DROP COVERAGE
        // You need a flag in your CpmPacket (from the monitor) that indicates a drop
        cp_drop: coverpoint local_packet.was_dropped {
            bins dropped = {1};
            option.comment = "Must hit at least once for closure";
        }

        cp_stall: coverpoint local_packet.was_stalled {
            bins stalled = {1}; 
        }
    endgroup

    function new(string name = "CoverageCollector", uvm_component parent);
        super.new(name, parent);
        StreamCoverage = new();
    endfunction

    virtual function void write(CpmPacket t);
        this.local_packet = t;

        if (m_regmodel != null) begin
            current_mode = m_regmodel.MODE.MODE_reg.get();
        end

        `uvm_info("COV_SAMPLE", $sformatf("Sampling: ID=%0h, Opcode=%0h, Mode=%0b, Stall=%0b", 
                  t.id, t.opcode, current_mode, t.was_stalled), UVM_HIGH)

        this.StreamCoverage.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        real total_cov = StreamCoverage.get_inst_coverage();
        `uvm_info("COV_FINAL", $sformatf("Final Coverage for %s: %0.2f%%", get_name(), total_cov), UVM_DEBUG)
    endfunction
endclass