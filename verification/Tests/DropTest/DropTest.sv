class DropTest extends CpmBaseTest;
    `uvm_component_utils(DropTest)

    function new(string name = "DropTest", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);

        CpmDropVirtualSequence vseq = CpmDropVirtualSequence::type_id::create("vseq");

        phase.raise_objection(this);
        // Connect the virtual sequence to the agent's sequencers.
        vseq.m_regmodel = m_env.m_regmodel;
        vseq.m_in_seqr  = m_env.m_in_agent.m_seqr;
        vseq.m_out_seqr = m_env.m_out_agent.m_seqr;

        // Start Virtual Sequence
        vseq.start(null);

        phase.drop_objection(this);


    endtask


endclass