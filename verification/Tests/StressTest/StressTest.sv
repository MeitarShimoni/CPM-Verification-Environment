
class StressTest extends CpmBaseTest;
    `uvm_component_utils(StressTest)

    function new(string name = "StressTest", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        CpmStressVirtualSequence vseq = CpmStressVirtualSequence::type_id::create("vseq");
        
        phase.raise_objection(this);
        
        vseq.m_regmodel = m_env.m_regmodel;
        vseq.m_in_seqr  = m_env.m_in_agent.m_seqr;
        vseq.m_out_seqr = m_env.m_out_agent.m_seqr;
        `uvm_info(get_type_name(), "Starting Stress Test Virtual Sequence", UVM_LOW)
        vseq.start(null);
        
        #500ns; 
        
        phase.drop_objection(this);
    endtask
endclass