#parse simulation target and time
set sim_mod [lindex $val 0]
set sim_time [lindex $val 1]

if {![string is double $sim_time]} {
	error "Invalid input parameter: $sim_time. Please input a decimal value to indicate \
			the number of micro-seconds (us) for simulation"
	exit
}
		
if {${sim_mod} != "alu" && ${sim_mod} != "reg_file"} { 
	error "Invalid input parameter: $sim_mod. Please input either alu or reg_file for behavioral simulation"
	exit
}

# add testbed file and set top module to sim_1
add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/${sim_mod}_test.v

# set verilog simulator 
set_property target_simulator "XSim" [current_project]

set_property runtime ${sim_time}us [get_filesets sim_1]
set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]

