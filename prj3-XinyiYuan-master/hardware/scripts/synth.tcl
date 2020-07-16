# setting Synthesis options
set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
# keep module port names in the netlist
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]
		
# synthesizing alu design
synth_design -top ${top_module} -part ${device} -mode out_of_context

# setup output logs and reports
report_utilization -hierarchical -file ${synth_rpt_dir}/${rpt_prefix}_util_hier.rpt
report_utilization -file ${synth_rpt_dir}/${rpt_prefix}_util.rpt

write_checkpoint -force ${dcp_dir}/${rpt_prefix}.dcp

