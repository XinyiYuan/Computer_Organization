
#parse names of benchmark and suite it belongs to 
set bench_suite [lindex $val 0]
set bench_name [lindex $val 1]
set sim_time [lindex $val 2]
set deadlock_sim [lindex $val 3] 

# add instruction stream for simulation
exec cp ${bench_dir}/${bench_suite}/sim/${bench_name}.coe ${sim_out_dir}/inst.coe 
		
add_files -norecurse -fileset sources_1 ${sim_out_dir}/inst.coe
update_compile_order -fileset [get_filesets sources_1]
		
add_files -norecurse -fileset sim_1 ${sim_out_dir}/inst.coe
update_compile_order -fileset [get_filesets sim_1]

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
	
add_files -norecurse -fileset sources_1 ${script_dir}/../${top_dir}/cpu_test_top.v
add_files -norecurse -fileset sim_1 ${script_dir}/../${top_dir}/cpu_test_top.v

add_files -norecurse -fileset sim_1 ${script_dir}/../${tb_dir}/cpu_test.v

set_property "top" cpu_test [get_filesets sim_1]

# set verilog simulator 
set_property target_simulator "XSim" [current_project]

set_property runtime ${sim_time}us [get_filesets sim_1]
set_property xsim.simulate.custom_tcl ${script_dir}/sim/xsim_run.tcl [get_filesets sim_1]

