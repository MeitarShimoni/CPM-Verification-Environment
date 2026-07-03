

import customtkinter as ctk
import subprocess
import random
import threading
import re # Added for parsing coverage output

# Appearance settings
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("blue")

class CpmRunner(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.title("CPM Verification Dashboard")
        self.geometry("1000x700")

        # Variables
        self.tests = ["CpmTest", "StressTest"]
        self.test_var = ctk.StringVar(value=self.tests[0])
        self.seed_var = ctk.StringVar(value="random")
        self.coverage_var = ctk.StringVar(value="Coverage: --%")

        # --- Layout ---
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

        # Side Panel
        self.sidebar = ctk.CTkFrame(self, width=250, corner_radius=0)
        self.sidebar.grid(row=0, column=0, sticky="nsew", padx=10, pady=10)
        
        ctk.CTkLabel(self.sidebar, text="Configuration", font=ctk.CTkFont(size=20, weight="bold")).pack(pady=20)

        # Select Test
        ctk.CTkLabel(self.sidebar, text="Select Test:").pack(pady=(10, 0))
        self.test_menu = ctk.CTkOptionMenu(self.sidebar, values=self.tests, variable=self.test_var, command=self.update_ui)
        self.test_menu.pack(pady=10)

        # Seed Entry
        ctk.CTkLabel(self.sidebar, text="Seed:").pack(pady=(10, 0))
        self.seed_entry = ctk.CTkEntry(self.sidebar, textvariable=self.seed_var)
        self.seed_entry.pack(pady=10)

        # Buttons
        self.run_btn = ctk.CTkButton(self.sidebar, text="Run Simulation", command=self.start_sim_thread, fg_color="green", hover_color="darkgreen")
        self.run_btn.pack(pady=20)

        # --- NEW: Coverage Display ---
        self.cov_frame = ctk.CTkFrame(self.sidebar, fg_color="#2b2b2b")
        self.cov_frame.pack(pady=10, padx=10, fill="x")
        
        self.cov_label = ctk.CTkLabel(self.cov_frame, textvariable=self.coverage_var, font=ctk.CTkFont(size=16, weight="bold"))
        self.cov_label.pack(pady=10)
        
        self.progress_bar = ctk.CTkProgressBar(self.cov_frame)
        self.progress_bar.set(0)
        self.progress_bar.pack(pady=10, padx=10)
        # -----------------------------

        self.comp_btn = ctk.CTkButton(self.sidebar, text="Compile (vlog)", command=self.compile_code)
        self.comp_btn.pack(pady=10)

        # Main Area
        self.main_frame = ctk.CTkFrame(self)
        self.main_frame.grid(row=0, column=1, sticky="nsew", padx=10, pady=10)
        
        ctk.CTkLabel(self.main_frame, text="Generated Command:", anchor="w").pack(fill="x", padx=10, pady=(10, 0))
        self.cmd_display = ctk.CTkTextbox(self.main_frame, height=60, fg_color="#1e1e1e", font=("Courier", 12))
        self.cmd_display.pack(fill="x", padx=10, pady=5)

        self.transcript = ctk.CTkTextbox(self.main_frame, fg_color="black", text_color="#00ff00", font=("Courier", 13))
        self.transcript.pack(fill="both", expand=True, padx=10, pady=10)

        self.update_ui()

    def update_ui(self, *args):
        test = self.test_var.get()
        seed_val = self.seed_var.get()
        seed = random.randint(1, 999999) if seed_val == "random" else seed_val
        
        # Added -coverage and coverage save command to the string [cite: 346]
        cmd = f"vsim -c -coverage tb_top +UVM_TESTNAME={test} -sv_seed {seed} -do \"run -all; coverage save -onexit sim_cov.ucdb; quit\""
        self.cmd_display.delete("1.0", "end")
        self.cmd_display.insert("1.0", cmd)

    def start_sim_thread(self):
        self.transcript.delete("1.0", "end")
        self.coverage_var.set("Running...")
        self.progress_bar.set(0)
        threading.Thread(target=self.run_command, args=(self.cmd_display.get("1.0", "end-1c"), True), daemon=True).start()

    def compile_code(self):
        cmd = "vlog -f files.f" 
        self.transcript.insert("end", f"\n>>> Compiling: {cmd}\n")
        threading.Thread(target=self.run_command, args=(cmd, False), daemon=True).start()

    def run_command(self, cmd, is_sim):
        process = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        for line in process.stdout:
            self.transcript.insert("end", line)
            self.transcript.see("end")
        process.wait()
        
        if is_sim:
            self.update_coverage_data()

    def update_coverage_data(self):
        """Extracts total coverage from the UCDB file using vcover report"""
        try:
            # Command to get a summary report from the saved database
            report_cmd = "vcover report -summary sim_cov.ucdb"
            result = subprocess.check_output(report_cmd, shell=True, text=True)
            
            # Look for a line like: "Total Coverage Summary: 85.5%"
            match = re.search(r"TOTAL COVERAGE = (\d+\.\d+)%", result)
            if match:
                percentage = float(match.group(1))
                self.coverage_var.set(f"Total Coverage: {percentage}%")
                self.progress_bar.set(percentage / 100.0)
                
                # Visual feedback for project targets 
                if percentage >= 80:
                    self.cov_label.configure(text_color="green")
                else:
                    self.cov_label.configure(text_color="yellow")
            else:
                self.coverage_var.set("Coverage: Error")
        except Exception as e:
            self.coverage_var.set("No UCDB found")

if __name__ == "__main__":
    app = CpmRunner()
    app.mainloop()