# parsing argument
if {$argc != 3} {
	puts "Error: The argument should be hw_act val output_dir"
	exit
} else {
	set act [lindex $argv 0]
	set val [lindex $argv 1]
	set out_dir [lindex $argv 2]
}

set script_dir [file dirname [info script]]
set top_module {}
	
source [file join $script_dir "prologue.tcl"]

if {$act == "rtl_chk" || $act == "sch_gen" || $act == "bhv_sim" || $act == "bit_gen"} {
	# project setup
	source [file join $script_dir "setup_prj.tcl"]

	if {$act == "rtl_chk" || $act == "sch_gen"} {
		if {$val != "alu" && $val != "reg_file"} {
			puts "Error: Your specified module name does not exist"
			exit
		}
		
		add_files -norecurse -fileset sources_1 ${script_dir}/../${src_dir}/${val}.v
		set top_module ${val} 

	} elseif {$act == "bhv_sim"} {
		source [file join $script_dir "sim_setup.tcl"]
		add_files -norecurse -fileset sources_1 ${script_dir}/../${src_dir}/${sim_mod}.v
		set top_module ${sim_mod}_test
	} else {
		add_files -norecurse -fileset sources_1 ${script_dir}/../${src_dir}/ 
		set top_module alu
	}
	
	# setting top module of sources_1 (set to FPGA top when creating this project)
	set_property "top" ${top_module} [get_filesets sources_1]
	update_compile_order -fileset [get_filesets sim_1]

	set_property source_mgmt_mode None [current_project]

	# Vivado operations
	if {$act == "rtl_chk" || $act == "sch_gen"} {
		# calling elabrated design
		synth_design -rtl -rtl_skip_constraints -rtl_skip_ip -top ${val}

		if {$act == "sch_gen"} {
			write_schematic -format pdf -force ${rtl_chk_dir}/${val}_sch.pdf
		}

	} elseif {$act == "bhv_sim"} {
		launch_simulation -mode behavioral -simset [get_filesets sim_1] 

	} elseif {$act == "bit_gen"} {
		set rpt_prefix synth

		# synthesis design
		source [file join $script_dir "synth.tcl"]
		# opt design
		source [file join $script_dir "opt.tcl"]
		# place design
		source [file join $script_dir "place.tcl"]
		# route design
		source [file join $script_dir "route.tcl"]
		# bitstream generation
		write_bitstream -no_partial_bitfile -force ${out_dir}/system.bit
	}
	close_project

	if {$act == "sch_gen"} {
		exit
	}

} elseif {$act == "wav_chk"} {

	if {$val != "alu" && $val != "reg_file"} {
		puts "Error: Please specify the name of waveform to be opened"
		exit
	}

	current_fileset

	open_wave_database ${sim_out_dir}/${val}.wdb
	open_wave_config ${sim_out_dir}/${val}.wcfg

} else {
	puts "Error: No specified actions for Vivado hardware project"
	exit
}

