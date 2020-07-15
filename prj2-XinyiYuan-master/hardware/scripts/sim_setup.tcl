set_property verilog_define { {MIPS_CPU_FULL_SIMU} {USE_MEM_INIT} } [get_filesets sources_1]
add_files -fileset constrs_1 -norecurse ${script_dir}/../constraints/mips_cpu_simu.xdc

#parse names of benchmark and suite it belongs to 
set bench_suite [lindex $val 0]
set bench_name [lindex $val 1]
set sim_time [lindex $val 2]

# add instruction stream for simulation
exec cp ${bench_dir}/${bench_suite}/sim/${bench_name}.mem ${sim_out_dir}/inst.mem 

add_files -norecurse -fileset sources_1 ${sim_out_dir}/inst.mem
update_compile_order -fileset [get_filesets sources_1]

add_files -norecurse -fileset sim_1 ${sim_out_dir}/inst.mem
update_compile_order -fileset [get_filesets sim_1]

# set verilog define value
set trace_file ${bench_dir}/${bench_suite}/sim/${bench_name}.mem.log
if {$act == "bhv_sim" && $bench_name != "test"} {
	set_property verilog_define "MIPS_CPU_FULL_SIMU USE_MEM_INIT TRACE_CMP TRACE_FILE=\"${trace_file}\"" [get_filesets sim_1]
} else {
	set_property verilog_define "MIPS_CPU_FULL_SIMU USE_MEM_INIT" [get_filesets sim_1]
}

# set verilog simulator 
set_property target_simulator "XSim" [current_project]

# add testbed file and set top module to sim_1
add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/mips_cpu_test.v
set_property "top" mips_cpu_test [get_filesets sim_1]
update_compile_order -fileset [get_filesets sim_1]

set_property runtime ${sim_time}us [get_filesets sim_1]
set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]
