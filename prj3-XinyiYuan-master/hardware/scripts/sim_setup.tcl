
#parse names of benchmark and suite it belongs to 
set bench_suite [lindex $val 0]
set bench_name [lindex $val 1]
set sim_time [lindex $val 2]
set deadlock_sim [lindex $val 3] 

set bench_name_deadlock mov-c

if { ${deadlock_sim} == "1" } {

	set sim_time [expr {$sim_time * 5}]

	# Generate block design of mpsoc for implementation 
	set bd_design mpsoc
	source ${script_dir}/${bd_design}.tcl
		
	set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
	generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
	make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
	import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

	validate_bd_design
	save_bd_design
	close_bd_design mpsoc

	# add instruction stream for simulation
	exec cp ${bench_dir}/${bench_suite}/sim/${bench_name}.txt ${sim_out_dir}/inst.txt 
	exec cp ${bench_dir}/${bench_suite}/sim/${bench_name_deadlock}.txt ${sim_out_dir}/inst_deadlock.txt 
		
	add_files -norecurse -fileset sources_1 ${sim_out_dir}/inst.txt
	add_files -norecurse -fileset sources_1 ${sim_out_dir}/inst_deadlock.txt
	update_compile_order -fileset [get_filesets sources_1]
		
	add_files -norecurse -fileset sim_1 ${sim_out_dir}/inst.txt
	add_files -norecurse -fileset sim_1 ${sim_out_dir}/inst_deadlock.txt
	update_compile_order -fileset [get_filesets sim_1]

	set_property verilog_define { {DEADLOCK_SIM} } [get_filesets sources_1]
	set_property verilog_define { {DEADLOCK_SIM} } [get_filesets sim_1]

	add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/mips_cpu_test.sv

} else {
	# add instruction stream for simulation
	exec cp ${bench_dir}/${bench_suite}/sim/${bench_name}.coe ${sim_out_dir}/inst.coe

	# Generate block design of mpsoc for implementation 
	set bd_design cpu_sim
	source ${script_dir}/${bd_design}.tcl
		
	set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
	generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
	make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
	import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

	validate_bd_design
	save_bd_design
	close_bd_design cpu_sim

	if {$act == "bhv_sim"} {
		set_property verilog_define { {NORM_SIMU} {BHV_UART_SIMU} } [get_filesets sources_1]
		set_property verilog_define { {NORM_SIMU} {BHV_UART_SIMU} } [get_filesets sim_1]
		add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/uart_recv_sim.v
	} else {
		set_property verilog_define { {NORM_SIMU} } [get_filesets sources_1]
		set_property verilog_define { {NORM_SIMU} } [get_filesets sim_1]
		add_files -fileset constrs_1 -norecurse ${script_dir}/../constraints/mips_cpu_simu.xdc
	}
		
	# add common file and set top module to sim_1
	add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/mips_cpu_test.v
}

set_property "top" mips_cpu_test [get_filesets sim_1]

# set verilog simulator 
set_property target_simulator "XSim" [current_project]

set_property runtime ${sim_time}us [get_filesets sim_1]
set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]

