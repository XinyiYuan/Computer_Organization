# setting Synthesis options
set_property strategy {Vivado Synthesis defaults} [get_runs synth_1]
# keep module port names in the netlist
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY {none} [get_runs synth_1]
		
# synthesizing adder design
synth_design -top adder -part ${device} -mode out_of_context

# setup output logs and reports
report_utilization -hierarchical -file ${synth_rpt_dir}/adder_util_hier.rpt
report_utilization -file ${synth_rpt_dir}/adder_util.rpt

write_checkpoint -force ${dcp_dir}/adder.dcp

# synthesizing counter design
synth_design -top counter -part ${device} -mode out_of_context

# setup output logs and reports
report_utilization -hierarchical -file ${synth_rpt_dir}/counter_util_hier.rpt
report_utilization -file ${synth_rpt_dir}/counter_util.rpt

write_checkpoint -force ${dcp_dir}/counter.dcp
