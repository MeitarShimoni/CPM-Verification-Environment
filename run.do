
echo "INFO: Starting simulation script..."
echo "PWD = [pwd]"

if {[file exists work]} {
  vdel -lib work -all
}
vlib work
vmap work work

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
  verification/Tests/DropTest/DropTestPkg.sv \
  verification/tb_top.sv

echo "INFO: Compilation Completed!"
#-debugDB 
# Use a unique WLF per run (avoids "vsim.wlf currently in use")
# set wlf_file [format "vsim_%s.wlf" [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]]
# -wlf $wlf_file
vsim -coverage -voptargs=+acc work.tb_top \
  +UVM_TESTNAME=SmokeTest \
  +UVM_VERBOSITY=UVM_LOW


# --- ADDING THE WAVEFORM FILE FROM SUBFOLDER ---
set wave_path "CONFIG/wave.do"

if {[file exists $wave_path]} {
    do $wave_path
} else {
    echo "WAVE: $wave_path not found, adding default signals instead."
    add wave -r sim:/tb_top/dut/*
}


onfinish stop
run -all


# NEW: Save the coverage data to a file after simulation completes
# coverage save cpm_test_coverage.ucdb

# NEW: Generate a readable report (optional but helpful)
#vcover report -details cpm_test_coverage.ucdb