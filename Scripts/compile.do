# Scripts/compile.do
onerror {quit -f}

# וודא שאנחנו יוצרים את הספרייה בתיקיית השורש (אחד למעלה מ-Scripts)
if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

echo "INFO: Compiling source files..."

# שימוש בנתיבים יחסיים מקובץ ה-Python (שורש הפרויקט)
vlog -sv \
  verification/cpm_verification_param_pkg.sv \
  design/cpm_rtl_update.sv \
  verification/Interfaces/input_streaming_if.sv \
  verification/Interfaces/output_streaming_if.sv \
  verification/Interfaces/reg_ctrl_if.sv \
  verification/Transactions/MyTransactionsPkg.sv \
  verification/RAL/design_pkg_uvm.sv \
  verification/Cpm_In_Agent/CpmInAgentPkg.sv \
  verification/Cpm_Out_Agent/CpmOutAgentPkg.sv \
  verification/Cpm_Reg_Agent/CpmRegAgentPkg.sv \
  verification/Environment/CpmEnvPkg.sv \
  verification/Sequences/CpmSequencePkg.sv \
  verification/Tests/CpmTestPkg.sv \
  verification/Tests/StressTest/StressTestPkg.sv \
  verification/Tests/SmokeTest/SmokeTestPkg.sv \
  verification/tb_top.sv

echo "INFO: Compilation completed successfully!"

quit -f