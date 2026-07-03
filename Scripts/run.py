import subprocess
import shutil
import glob
import os
import argparse
import sys

# === CONFIG ===
TB   = "tb_top"      
SNAP = f"{TB}_opt"   

def run_command(command, step_name, cwd=None):
    print(f"\n--- INFO: Starting Step: {step_name} ---")
    # Using shell=True and passing the directory context
    return_code = subprocess.call(command, shell=True, cwd=cwd)
    if return_code != 0:
        print(f"--- ERROR: Step '{step_name}' failed ---")
        sys.exit(1)

def cleanup(work_dir):
    print("INFO: Cleaning up...")
    # Clean in the folder where the work library actually is
    for d in [os.path.join(work_dir, "work"), os.path.join(work_dir, SNAP)]:
        if os.path.exists(d):
            shutil.rmtree(d, ignore_errors=True)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--gui', action='store_true')
    parser.add_argument('--seed', type=int, default=1)
    parser.add_argument('--test', type=str, default='SmokeTest') # chose a name!
    args = parser.parse_args()

    # Determine paths: Script is in /Scripts, Root is one level up
    script_dir = os.path.dirname(os.path.abspath(__file__))
    root_dir = os.path.abspath(os.path.join(script_dir, ".."))
    
    # Switch Python's context to the root directory
    os.chdir(root_dir)
    print(f"--- INFO: Working Directory set to: {root_dir} ---")

    cleanup(root_dir)

    # 1. Compile (Passing the relative path to the .do file)
    run_command('vsim -c -do "do Scripts/compile.do"', "Compile")

    # 2. Elaborate
    run_command('vsim -c -do "do Scripts/elaborate.do"', "Elaborate")

    # 3. Simulate
    log_file = f"{args.test}_{args.seed}.log"
    cmd = f"vsim -debugDB -voptargs=+acc -sv_seed {args.seed} " \
          f"+UVM_TESTNAME={args.test} +UVM_VERBOSITY=UVM_LOW {SNAP}"

    if args.gui:
        tcl = [
            'set wave_path "CONFIG/wave.do"',
            f'if {{[file exists $wave_path]}} {{do $wave_path}} else {{add wave -r sim:/{TB}/*}}',
            "onfinish stop",
            "run -all"
            # ,
            # "coverage save cov.ucdb"
        ]
        cmd += f' -gui -do "{"; ".join(tcl)}"'

    else:
        tcl = ["run -all", "coverage save cov.ucdb", "quit -f"]
        cmd += f' -c -logfile {log_file} -do "{"; ".join(tcl)}"'

    run_command(cmd, "Simulate")