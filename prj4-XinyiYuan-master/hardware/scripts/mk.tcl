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
		set top_module custom_cpu
	} else {
		add_files -norecurse -fileset sources_1 ${script_dir}/../${top_dir}/cpu_top.v
		add_files -norecurse -fileset sources_1 ${script_dir}/../${top_dir}/cpu_wrapper.v

		if {$act == "bit_gen"} {
			source [file join $script_dir "custom_cpu_wrapper.tcl"]

			add_files -norecurse -fileset sources_1 ${script_dir}/../shell/cpu_fixed.dcp
			set top_module cpu_top
			
			set ila_cfg_num [lindex $val 0] 
			# setup ILA hardware debugger if HW_ACT is specified 
			if {${ila_cfg_num} != "0"} {
				source [file join $script_dir "ila_setup.tcl"]
			}
		} else {
			add_files -norecurse -fileset sources_1 ${script_dir}/../${top_dir}/cpu_fpga.v
			set top_module cpu_fpga
		}
	}

	set_property "top" ${top_module} [get_filesets sources_1]
	update_compile_order -fileset [get_filesets sources_1]
	
	if {$act == "bhv_sim"} {
		source [file join $script_dir "sim_setup.tcl"]
	}

	set_property source_mgmt_mode None [current_project]

	# Vivado operations
	if {$act == "rtl_chk" || $act == "sch_gen"} {
		# calling elabrated design
		synth_design -rtl -rtl_skip_constraints -rtl_skip_ip -top ${top_module}

		if {$act == "sch_gen"} {
			write_schematic -format pdf -force ${rtl_chk_dir}/${top_module}_sch.pdf
			exit
		}

	} elseif {$act == "bit_gen"} {
		set rpt_prefix synth
		# synthesis design
		source [file join $script_dir "synth.tcl"]
		# opt design
		source [file join $script_dir "opt.tcl"]
		# Save debug nets file
		write_debug_probes -force ${out_dir}/debug_nets.ltx
		# place design
		source [file join $script_dir "place.tcl"]
		# route design
		source [file join $script_dir "route.tcl"]
		# bitstream generation
		write_bitstream -no_partial_bitfile -force ${out_dir}/system.bit

	} elseif {$act == "bhv_sim"} {
		launch_simulation -mode behavioral -simset [get_filesets sim_1] 
	}
	close_project

} elseif {$act == "wav_chk"} {

	if {$val != "bhv"} {
		puts "Error: Please specify the name of waveform to be opened"
		exit
	}

	current_fileset

	set file_name behav

	open_wave_database ${sim_out_dir}/${file_name}.wdb
	open_wave_config ${sim_out_dir}/${file_name}.wcfg

} elseif {$act == "dcp_chk"} {

	if {$val != "synth" && $val != "place" && $val != "route"} {
		puts "Error: Please specify the name of .dcp file to be opened"
		exit
	}
	open_checkpoint ${dcp_dir}/${val}.dcp

} else {
	puts "Error: No specified actions for Vivado hardware project"
	exit
}

