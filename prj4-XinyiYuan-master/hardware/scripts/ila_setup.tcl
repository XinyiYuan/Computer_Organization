set i 0
while {$i < ${ila_cfg_num}} {
	set idx [expr $i + 1]
	set ila_conf [lindex $val $idx]
	source ${script_dir}/ila.tcl
					
	set_property synth_checkpoint_mode None [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd]
	generate_target all [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd]
				
	make_wrapper -files [get_files ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/${ila_conf}.bd] -top
	import_files -force -norecurse -fileset sources_1 ./${project_name}/${project_name}.srcs/sources_1/bd/${ila_conf}/hdl/${ila_conf}_wrapper.v
				
	validate_bd_design
	save_bd_design
	close_bd_design ${ila_conf}

	incr i 1
}
