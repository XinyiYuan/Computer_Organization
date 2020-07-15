set cpu_freq 100 
set bd_design cpu_clk
source ${script_dir}/${bd_design}.tcl
		
set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd]
		
make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/${bd_design}.bd] -top
import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${bd_design}/hdl/${bd_design}_wrapper.v

validate_bd_design
save_bd_design
close_bd_design cpu_clk

