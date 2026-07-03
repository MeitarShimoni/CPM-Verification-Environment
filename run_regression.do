echo "INFO: Starting regression..."
echo "PWD = [pwd]"

# -------------------------
# Build work + compile ONCE
# -------------------------
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
  verification/Cpm_In_Agent/CpmInAgentPkg.sv \
  verification/Cpm_Out_Agent/CpmOutAgentPkg.sv \
  verification/Cpm_Reg_Agent/CpmRegAgentPkg.sv \
  verification/RAL/design_pkg_uvm.sv \
  verification/Environment/CpmEnvPkg.sv \
  verification/Sequences/CpmSequencePkg.sv \
  verification/Tests/CpmTestPkg.sv \
  verification/Tests/StressTest/StressTestPkg.sv \
  verification/Tests/SmokeTest/SmokeTestPkg.sv \
  verification/tb_top.sv

echo "INFO: Compilation Completed!"

# -------------------------
# Regression loop
# -------------------------
set tests [list SmokeTest StressTest]
set wave_path "CONFIG/wave.do"

foreach t $tests {
  echo "\n=================================================="
  echo "INFO: Running test: $t"
  echo "=================================================="

  # Unique wave database per run (optional but recommended)
  # set wlf_file [format "vsim_%s_%s.wlf" $t [clock format [clock seconds] -format "%Y%m%d_%H%M%S"]]

  # Start fresh sim for this test
  vsim -coverage -voptargs=+acc work.tb_top \
    +UVM_TESTNAME=$t \
    +UVM_VERBOSITY=UVM_LOW

  # Waves (optional)
  if {[file exists $wave_path]} {
    do $wave_path
  } else {
    echo "WAVE: $wave_path not found, adding default signals instead."
    add wave -r sim:/tb_top/dut/*
  }

  onfinish stop
  run -all

  # Save UCDB per test
  set ucdb_file [format "cov_%s.ucdb" $t]
  coverage save $ucdb_file
  echo "INFO: Saved coverage to $ucdb_file"

  # End this sim instance before next test
  quit -sim
}

# -------------------------
# Optional: merge + report
# -------------------------
# Merge per-test coverage into one DB
vcover merge cov_merged.ucdb cov_SmokeTest.ucdb cov_StressTest.ucdb

# Generate a detailed report
vcover report -details cov_merged.ucdb > cov_report.txt
echo "INFO: Coverage merged into cov_merged.ucdb and report written to cov_report.txt"

echo "INFO: Regression finished."
quit -f
