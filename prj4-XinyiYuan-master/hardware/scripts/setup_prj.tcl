# project name
set project_name prj_4
	
# device and board
set device xczu2eg-sfva625-1-e
set board interwiser:none:part0:2.0

# setting up the project
create_project ${project_name} -force -dir "./${project_name}" -part ${device}
set_property board_part ${board} [current_project]

# add source files	
add_files -norecurse -fileset sources_1 ${script_dir}/../${cpu_dir}/
