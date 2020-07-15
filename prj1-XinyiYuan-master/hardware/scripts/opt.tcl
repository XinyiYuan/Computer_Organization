# open shell checkpoint
open_checkpoint ${script_dir}/../shell/shell.dcp

# open role checkpoint
read_checkpoint -cell [get_cells mpsoc_i/u_alu/inst] ${dcp_dir}/alu.dcp
read_checkpoint -cell [get_cells mpsoc_i/u_reg_file/inst] ${dcp_dir}/reg_file.dcp

# setup output logs and reports
report_timing_summary -file ${synth_rpt_dir}/${rpt_prefix}_timing.rpt -delay_type max -max_paths 1000

# Design optimization
opt_design

