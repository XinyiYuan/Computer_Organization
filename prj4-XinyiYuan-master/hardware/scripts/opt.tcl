# open shell checkpoint
open_checkpoint ${script_dir}/../shell/shell.dcp

# open role checkpoint
read_checkpoint -cell [get_cells u_cpu_top] ${dcp_dir}/${rpt_prefix}.dcp

# setup output logs and reports
report_timing_summary -file ${synth_rpt_dir}/${rpt_prefix}_timing.rpt -delay_type max -max_paths 1000

# Design optimization
opt_design

