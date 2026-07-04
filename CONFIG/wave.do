onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top/dut/clk
add wave -noupdate /tb_top/dut/rst
add wave -noupdate -expand -group {Input Streaming} -color {Medium Violet Red} -label in_valid /tb_top/dut/in_valid
add wave -noupdate -expand -group {Input Streaming} -label in_ready /tb_top/dut/in_ready
add wave -noupdate -expand -group {Input Streaming} -color Magenta -label in_id /tb_top/dut/in_id
add wave -noupdate -expand -group {Input Streaming} -color Magenta -label in_opcode /tb_top/dut/in_opcode
add wave -noupdate -expand -group {Input Streaming} -color Magenta -label in_payload /tb_top/dut/in_payload
add wave -noupdate -expand -group {Output Streaming} -label out_valid /tb_top/dut/out_valid
add wave -noupdate -expand -group {Output Streaming} -color {Medium Violet Red} -label out_ready /tb_top/dut/out_ready
add wave -noupdate -expand -group {Output Streaming} -color Magenta -label out_id /tb_top/dut/out_id
add wave -noupdate -expand -group {Output Streaming} -color Magenta -label out_opcode /tb_top/dut/out_opcode
add wave -noupdate -expand -group {Output Streaming} -color Magenta -label out_payload /tb_top/dut/out_payload
add wave -noupdate -expand -group {Input Reg Ctrl } -color Magenta -label req /tb_top/dut/req
add wave -noupdate -expand -group {Input Reg Ctrl } -label gnt /tb_top/dut/gnt
add wave -noupdate -expand -group {Input Reg Ctrl } -color Magenta -label write_en /tb_top/dut/write_en
add wave -noupdate -expand -group {Input Reg Ctrl } -color Magenta -label addr /tb_top/dut/addr
add wave -noupdate -expand -group {Input Reg Ctrl } -color Magenta -label wdata /tb_top/dut/wdata
add wave -noupdate -expand -group {Input Reg Ctrl } -label rdata /tb_top/dut/rdata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {713 ns} 0} {{Cursor 2} {2751 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {2987 ns}
