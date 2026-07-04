

`uvm_analysis_imp_decl(_expected)
`uvm_analysis_imp_decl(_actual)

class CpmScoreboard extends uvm_scoreboard;
  `uvm_component_utils(CpmScoreboard)

  uvm_analysis_imp_expected #(CpmPacket, CpmScoreboard) m_expected_export;
  uvm_analysis_imp_actual   #(CpmPacket, CpmScoreboard) m_actual_export;

  CpmPacket exp_by_id [bit [3:0]];
  CpmPacket act_by_id [bit [3:0]];

  int mismatches = 0;
  int exp_in = 0;
  int act_in = 0;
  int matched = 0;

  function new(string name="CpmScoreboard", uvm_component parent=null);
    super.new(name,parent);
    m_expected_export = new("m_expected_export", this);
    m_actual_export   = new("m_actual_export", this);
  endfunction

  function void write_expected(CpmPacket p);
    CpmPacket c;
    if (p==null) return;
    c = CpmPacket::type_id::create("exp", this);
    c.copy(p);
    exp_in++;

    exp_by_id[c.id] = c;
    if (act_by_id.exists(c.id)) do_compare_id(c.id);
  endfunction

  function void write_actual(CpmPacket p);
    CpmPacket c;
    if (p==null) return;
    c = CpmPacket::type_id::create("act", this);
    c.copy(p);
    act_in++;

    act_by_id[c.id] = c;
    if (exp_by_id.exists(c.id)) do_compare_id(c.id);
  endfunction

  function void do_compare_id(bit [3:0] id);
    CpmPacket e = exp_by_id[id];
    CpmPacket a = act_by_id[id];

    exp_by_id.delete(id);
    act_by_id.delete(id);
    matched++;

    if (!e.compare(a)) begin
      mismatches++;
      `uvm_error("SCB_MISMATCH",
        $sformatf("ID=%0h mismatch!\nEXP: %s\nACT: %s", id, e.sprint(), a.sprint())) //summary
        // $sformatf("ID=%0h mismatch!\nEXP: %s\nACT: %s", id, e.summary(), a.summary()))
    end
  endfunction

  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (exp_by_id.num() != 0 || act_by_id.num() != 0) begin
      `uvm_error("SCB_LEFTOVER",
        $sformatf("Leftovers: exp_left=%0d act_left=%0d", exp_by_id.num(), act_by_id.num()))
    end

    if (mismatches==0 && exp_by_id.num()==0 && act_by_id.num()==0)
      `uvm_info("SCB_PASS", $sformatf("PASS exp_in=%0d act_in=%0d matched=%0d", exp_in, act_in, matched), UVM_LOW)
    else
      `uvm_error("SCB_FAIL", $sformatf("FAIL mismatches=%0d exp_in=%0d act_in=%0d matched=%0d",
                                       mismatches, exp_in, act_in, matched))
  endfunction
endclass
