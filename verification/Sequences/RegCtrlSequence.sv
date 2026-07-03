

class RegCtrlSequence extends uvm_sequence #(uvm_sequence_item); 
  `uvm_object_utils(RegCtrlSequence)
  
  cpm_reg_map m_regmodel; // Handle למודל

  virtual task body();
    uvm_status_e status;
    uvm_reg_data_t rd;

    // שימוש ב-RAL במקום בכתובות ידניות
    m_regmodel.CTRL.write(status, 32'h1, .parent(this));         // ENABLE=1
    m_regmodel.PARAMS.MASK.set(16'hFFFF);                       // הגדרת שדה ספציפי
    m_regmodel.PARAMS.update(status, .parent(this));            // עדכון הרגיסטר
    m_regmodel.MODE.write(status, 32'h1, .parent(this));         // XOR_MODE

    // קריאת סטטוס
    m_regmodel.STATUS.read(status, rd, .parent(this));
    `uvm_info(get_type_name(), $sformatf("STATUS=0x%0h", rd), UVM_MEDIUM)
  endtask
endclass