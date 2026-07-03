
class RefModel extends uvm_component;
  `uvm_component_utils(RefModel)

  uvm_analysis_imp  #(CpmPacket, RefModel) in_ap;
  uvm_analysis_port #(CpmPacket)          out_ap;

  cpm_reg_map m_regmodel;
  logic [3:0] m_rot_amt = 4'd4; 

  function new(string name="RefModel", uvm_component parent=null);
    super.new(name, parent);
    in_ap  = new("in_ap",  this);
    out_ap = new("out_ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if (!uvm_config_db#(cpm_reg_map)::get(this, "", "regmodel", m_regmodel)) begin
      `uvm_fatal("REF_CFG", "RefModel: Missing regmodel in config_db (key='regmodel')")
    end
    if (m_regmodel == null) begin
      `uvm_fatal("REF_CFG", "RefModel: regmodel is NULL")
    end
  endfunction

  function automatic logic [15:0] rol16(logic [15:0] x, int unsigned sh);
    int unsigned s;
    s = sh % 16;
    return (x << s) | (x >> (16 - s));
  endfunction

  function void write(CpmPacket i_pkt);
    CpmPacket exp;

    uvm_reg_data_t enable_v, mode_v, mask_v, addc_v, drop_en_v, drop_opc_v;

    bit          en;
    bit [1:0]    mode;
    logic [15:0] mask;
    logic [15:0] addc;
    bit          drop_en;
    logic [3:0]  drop_opc;
    logic [3:0]  rot_amt;

    if (i_pkt == null) return;

    // ===== READ MIRRORED VALUES (predictor must update mirror) =====
    enable_v   = m_regmodel.CTRL.ENABLE.get_mirrored_value();
    mode_v     = m_regmodel.MODE.MODE_reg.get_mirrored_value();
    mask_v     = m_regmodel.PARAMS.MASK.get_mirrored_value();
    addc_v     = m_regmodel.PARAMS.ADD_CONST.get_mirrored_value();
    drop_en_v  = m_regmodel.DROP_CFG.DROP_EN.get_mirrored_value();
    drop_opc_v = m_regmodel.DROP_CFG.DROP_OPCODE.get_mirrored_value();

    en       = enable_v[0];
    mode     = mode_v[1:0];
    mask     = mask_v[15:0];
    addc     = addc_v[15:0];
    drop_en  = drop_en_v[0];
    drop_opc = drop_opc_v[3:0];
    rot_amt  = m_rot_amt;

    if (!en) begin
      `uvm_warning("REF_EN0",
        $sformatf("ENABLE=0 but got input pkt id=%0h opcode=%0h (check enable write/predictor timing)",
                  i_pkt.id, i_pkt.opcode))
      return;
    end

    if (drop_en && (i_pkt.opcode == drop_opc)) begin
      `uvm_info("REF_DROP",
        $sformatf("Dropped pkt id=%0h opcode=%0h (DROP_CFG active)", i_pkt.id, i_pkt.opcode),
        UVM_MEDIUM)
      return;
    end

    exp = CpmPacket::type_id::create("expected_pkt", this);
    exp.copy(i_pkt);

    unique case (mode)
      2'd0: exp.payload = i_pkt.payload;                 // PASS
      2'd1: exp.payload = i_pkt.payload ^ mask;          // XOR
      2'd2: exp.payload = i_pkt.payload + addc;          // ADD
      2'd3: exp.payload = rol16(i_pkt.payload, rot_amt); // ROT
      default: exp.payload = i_pkt.payload;
    endcase

    out_ap.write(exp);
  endfunction

endclass
