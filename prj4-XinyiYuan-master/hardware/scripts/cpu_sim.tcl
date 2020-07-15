#========================================================
# Vivado BD design auto run script for MPSoC in ZCU102
# Based on Vivado 2017.2
# Author: Yisong Chang (changyisong@ict.ac.cn)
# Date: 22/12/2017
#========================================================

namespace eval mpsoc_bd_val {
	set design_name cpu_sim
	set bd_prefix ${mpsoc_bd_val::design_name}_

}


# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${mpsoc_bd_val::design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne ${mpsoc_bd_val::design_name} } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <${mpsoc_bd_val::design_name}> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq ${mpsoc_bd_val::design_name} } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${mpsoc_bd_val::design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <${mpsoc_bd_val::design_name}> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <${mpsoc_bd_val::design_name}> in project, so creating one..."

   create_bd_design ${mpsoc_bd_val::design_name}

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <${mpsoc_bd_val::design_name}> as current_bd_design."
   current_bd_design ${mpsoc_bd_val::design_name}

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"${mpsoc_bd_val::design_name}\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

##################################################################
# DESIGN PROCs
##################################################################

# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

#=============================================
# Create IP blocks
#=============================================

  # Create instance: AXI block RAM interface
  set axi_bram_if [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_if ] 
  set_property -dict [ list CONFIG.SINGLE_PORT_BRAM {1} \
					CONFIG.PROTOCOL {AXI4} \
					CONFIG.MEM_DEPTH {16384} ] ${axi_bram_if}

  # Create instance: block RAM entity
  set sys_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 sys_bram ] 
  set_property -dict [ list CONFIG.use_bram_block {Stand_Alone} \
					CONFIG.Enable_32bit_Address {true} \
					CONFIG.Write_Depth_A {16384} \
					CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
					CONFIG.Load_Init_File {true} \
					CONFIG.Coe_File "${::sim_out_dir}/inst.coe" \
					CONFIG.Fill_Remaining_Memory_Locations {true} ] ${sys_bram}

  # Create instance: AXI UART controller 
  set axi_uart [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uart ]
  set_property -dict [list CONFIG.C_BAUDRATE {115200}] $axi_uart

  # Create interconnect
  set cpu_ddr_ic [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 cpu_ddr_ic ]
  set_property -dict [list CONFIG.NUM_MI {2} CONFIG.NUM_SI {2}] $cpu_ddr_ic

  # Create instance: Reset infrastructure for ARM and MIPS sub systems
  set zynq_reset_infra [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 zynq_reset_infra ]

#=============================================
# Clock ports
#=============================================

  create_bd_port -dir I -type clk sys_clk

  # system clock output
  create_bd_port -dir O -type clk system_clk

#==============================================
# Reset ports
#==============================================

  # System reset_n
  create_bd_port -dir I -type rst sys_reset_n

  create_bd_port -dir O -type rst cpu_reset_n

#==============================================
# Other ports
#==============================================
  create_bd_port -dir O uart_tx

#==============================================
# Export AXI Interface
#==============================================

  # CPU Inst and Data memory port
  set cpu_inst [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 cpu_inst]
  set_property -dict [ list CONFIG.READ_WRITE_MODE {READ_ONLY} \
				CONFIG.ID_WIDTH {0} \
				CONFIG.HAS_CACHE {0} \
				CONFIG.HAS_LOCK {0} \
				CONFIG.HAS_PROT {0} \
				CONFIG.HAS_REGION {0} \
				CONFIG.HAS_QOS {0} ] $cpu_inst

  set cpu_mem [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 cpu_mem]
  set_property -dict [ list CONFIG.ID_WIDTH {0} \
				CONFIG.HAS_CACHE {0} \
				CONFIG.HAS_LOCK {0} \
				CONFIG.HAS_PROT {0} \
				CONFIG.HAS_REGION {0} \
				CONFIG.HAS_QOS {0} ] $cpu_mem

  set_property CONFIG.ASSOCIATED_BUSIF {cpu_inst:cpu_mem} [get_bd_ports system_clk]

#=============================================
# System clock connection
#=============================================
  connect_bd_net -net armv8_ps_fclk_0 [get_bd_ports sys_clk] \
			[get_bd_pins zynq_reset_infra/slowest_sync_clk] \
			[get_bd_pins cpu_ddr_ic/*ACLK] \
			[get_bd_pins axi_bram_if/s_axi_aclk] \
			[get_bd_pins axi_uart/s_axi_aclk] \
			[get_bd_ports system_clk]

#=============================================
# System reset connection
#=============================================
  connect_bd_net -net ps_user_reset_n [get_bd_ports sys_reset_n] \
			[get_bd_pins zynq_reset_infra/ext_reset_in]

  connect_bd_net -net zynq_perip_resetn [get_bd_pins zynq_reset_infra/peripheral_aresetn] \
			[get_bd_ports cpu_reset_n] \
			[get_bd_pins cpu_ddr_ic/*_ARESETN] \
			[get_bd_pins axi_uart/s_axi_aresetn] \
			[get_bd_pins axi_bram_if/s_axi_aresetn]

  connect_bd_net -net zynq_ic_resetn [get_bd_pins zynq_reset_infra/interconnect_aresetn] \
			[get_bd_pins arm_axi_ic/ARESETN] \
			[get_bd_pins cpu_ddr_ic/ARESETN]

#==============================================
# AXI Interface Connection
#==============================================

  # Custom CPU inst and data port to DDR
  connect_bd_intf_net -intf_net hp0_ddr [get_bd_intf_pins axi_bram_if/S_AXI] \
			[get_bd_intf_pins cpu_ddr_ic/M00_AXI]

  connect_bd_intf_net -intf_net cpu_inst [get_bd_intf_pins cpu_ddr_ic/S00_AXI] \
			[get_bd_intf_pins cpu_inst]

  connect_bd_intf_net -intf_net cpu_mem [get_bd_intf_pins cpu_ddr_ic/S01_AXI] \
			[get_bd_intf_pins cpu_mem]

  connect_bd_intf_net -intf_net axi_uart [get_bd_intf_pins cpu_ddr_ic/M01_AXI] \
			[get_bd_intf_pins axi_uart/S_AXI]

#=============================================
# Other ports
#=============================================
  connect_bd_net -net uart_rx [get_bd_pins axi_uart/tx] [get_bd_ports uart_tx]

  connect_bd_intf_net [get_bd_intf_pins axi_bram_if/BRAM_PORTA] [get_bd_intf_pins sys_bram/BRAM_PORTA]

#=============================================
# Create address segments
#=============================================

  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces cpu_inst] [get_bd_addr_segs axi_bram_if/S_AXI/Mem0] CPU_INST
  create_bd_addr_seg -range 0x40000000 -offset 0x40000000 [get_bd_addr_spaces cpu_mem] [get_bd_addr_segs axi_bram_if/S_AXI/Mem0] cpu_mem
  create_bd_addr_seg -range 0x1000 -offset 0x80010000 [get_bd_addr_spaces cpu_mem] [get_bd_addr_segs axi_uart/S_AXI/Reg] CPU_UART

#=============================================
# Finish BD creation 
#=============================================

  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""

